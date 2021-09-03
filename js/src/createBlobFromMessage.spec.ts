import { createBlobFromMessage } from './createBlobFromMessage'
import { Message } from './Message'

describe(createBlobFromMessage, () => {
  it('converts a message to a blob', async () => {
    const message: Message = {
      headers: {
        'Interop-Rpc-Class': 'foo',
        'Interop-Rpc-Id': 'bar'
      },
      body: new Blob(['baz'])
    }
    const result = createBlobFromMessage(message)
    expect(result).toBeInstanceOf(Blob)
    const text = await result.text()
    const expected = `
Interop-Rpc-Class: foo
Interop-Rpc-Id: bar

baz
`.slice(1)
    expect(text).toBe(expected)
  })
})
