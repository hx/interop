import { CreateMessageFunc, createMessageBase } from './createMessage'
import { Header } from './Header'
import { RpcMessage } from './RpcMessage'

const sessionId = Math.floor(Math.random() * 1e9)
let nextId = 0

export const createRpcMessageBase = async (...args: unknown[]) => {
  const message = await createMessageBase(...args)
  message.headers[Header.ID] = `${sessionId}.${++nextId}`
  return message as RpcMessage
}

export const createRpcMessage = createRpcMessageBase as CreateMessageFunc<RpcMessage>
