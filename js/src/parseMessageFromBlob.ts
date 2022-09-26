import { Header } from './Header'
import { Message } from './Message'
import { canonicalizeKey, mapToObj } from './utilities'
import { Headers } from './Headers'

const CarriageReturn = '\r'.charCodeAt(0)
const LineFeed       = '\n'.charCodeAt(0)

const endsWithDoubleLineBreak = async (blob: Blob): Promise<boolean> => {
  const end = new Uint8Array(await blob.slice(-4).arrayBuffer()).filter(x => x !== CarriageReturn).slice(-2)

  return end[0] === LineFeed && end[1] === LineFeed
}

const extractHeadersFromBlob = async (blob: Blob): Promise<Blob> => {
  const chunkSize = 64
  let headerView = blob.slice(0, 0)

  for (let offset = 0, done = false; offset < blob.size && !done; offset += chunkSize) {
    const bytes = new Uint8Array(await blob.slice(offset, offset + chunkSize).arrayBuffer())
    for (let cursor = 0; !done; cursor++) {
      cursor = bytes.indexOf(LineFeed, cursor)
      if (cursor === -1) {
        break
      }
      headerView = blob.slice(0, offset + cursor + 1)
      done = await endsWithDoubleLineBreak(headerView)
    }
  }

  return headerView
}

export const parseMessageFromBlob = async (blob: Blob): Promise<Message> => {
  const headerBlob   = await extractHeadersFromBlob(blob)
  const headerString = await headerBlob.text()
  const headers      = mapToObj(headerString.trim().split(/\r?\n/), line => {
    const splitAt = line.indexOf(':')
    if (splitAt === -1) {
      throw new Error(`Expected a colon in "${line}`)
    }
    return [
      canonicalizeKey(line.slice(0, splitAt)),
      line.slice(splitAt + 1).trimStart()
    ]
  }) as unknown as Headers

  let body = blob.slice(headerBlob.size)

  if (Header.Length in headers) {
    const length = parseInt(headers[Header.Length] as string)
    let newLine = await body.slice(length, length+2).text()
    if (newLine.charCodeAt(0) === CarriageReturn) {
      newLine = newLine.slice(1)
    }
    if (newLine.charCodeAt(0) !== LineFeed) {
      throw new Error(`Expected a newline after ${length} bytes; got "${newLine}"`)
    }
    body = body.slice(0, length)
  }

  return {headers, body}
}
