import { Header } from './Header'
import { Message } from './Message'
import { mapToObj } from './utilities'
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

const canonicalizeKey = (key: string) =>
  key.split(/[-_\s]+/).map(s => s.charAt(0).toUpperCase() + s.slice(1).toLowerCase()).join('-')

export const parseMessageFromBlob = async (blob: Blob): Promise<Message> => {
  const headerBlob   = await extractHeadersFromBlob(blob)
  const headerString = await headerBlob.text()
  const headers      = mapToObj(headerString.trim().split(/\r?\n/), line => {
    const [k, v] = line.split(/:\s?/, 2)
    return [canonicalizeKey(k), v || '']
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
