import { createRpcRequestMessage } from './createRpcRequestMessage'
import { messageClass, messageError, messageID } from './messages'
import { isRpcRequestMessage } from './RpcRequestMessage'

describe(createRpcRequestMessage, () => {
  it('can create a message with just a class name', async () => {
    const message = await createRpcRequestMessage('booyaa')
    expect(isRpcRequestMessage(message)).toBe(true)
    expect(messageError(message)).toBeUndefined()
    expect(messageClass(message)).toBe('booyaa')
    expect(messageID(message)).toMatch(/^\d{9}\.\d+$/)
  })
})
