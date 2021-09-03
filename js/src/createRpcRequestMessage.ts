import { ContentType } from './ContentType'
import { createRpcMessageBase } from './createRpcMessage'
import { Header } from './Header'
import { Headers } from './Headers'
import { Message } from './Message'
import { RpcRequestMessage } from './RpcRequestMessage'

interface CreateRpcRequestMessageFunc<M extends Message = RpcRequestMessage> {
  (className: string): Promise<M>
  (className: string, body: Blob): Promise<M>
  (className: string, contentType: ContentType, content?: unknown): Promise<M>
  (className: string, headers: Headers): Promise<M>
  (className: string, headers: Headers, body: Blob): Promise<M>
  (className: string, headers: Headers, contentType: ContentType, content?: unknown): Promise<M>
}

export const createRpcRequestMessage: CreateRpcRequestMessageFunc = async (className: string, ...args: unknown[]) => {
  const message = await createRpcMessageBase(...args)
  message.headers[Header.Class] = className
  return message as RpcRequestMessage
}
