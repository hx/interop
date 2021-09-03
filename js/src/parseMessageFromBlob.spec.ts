import { isMessage } from './Message'
import { parseMessageFromBlob } from './parseMessageFromBlob'

describe(parseMessageFromBlob, () => {
  const raw = new Blob([`
Content-Type: application/json
Content-length: 13

{"foo":"bar"}
`.slice(1)])

  it('can decode a regular message', async () => {
    const result = await parseMessageFromBlob(raw)
    expect(isMessage(result)).toBe(true)
    expect(result.headers['Content-Type']).toBe('application/json')
    expect(result.headers['Content-Length']).toBe('13')
    const text = await result.body.text()
    expect(text).toBe('{"foo":"bar"}')
  })
})
