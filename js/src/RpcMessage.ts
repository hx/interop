import { Message, isMessage } from './Message'
import { RpcHeaders, isRpcHeaders } from './RpcHeaders'

export type RpcMessage = Message<RpcHeaders>

export const isRpcMessage = (obj: unknown): obj is RpcMessage =>
  isMessage(obj) && isRpcHeaders(obj.headers)
