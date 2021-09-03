import { Message, isMessage } from './Message'
import { RpcRequestHeaders, isRpcRequestHeaders } from './RpcRequestHeaders'

export type RpcRequestMessage = Message<RpcRequestHeaders>

export const isRpcRequestMessage = (obj: unknown): obj is RpcRequestMessage =>
  isMessage(obj) && isRpcRequestHeaders(obj.headers)
