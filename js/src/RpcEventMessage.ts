import { Message, isMessage } from './Message'
import { RpcEventHeaders, isRpcEventHeaders } from './RpcEventHeaders'

export type RpcEventMessage = Message<RpcEventHeaders>

export const isRpcEventMessage = (obj: unknown): obj is RpcEventMessage =>
  isMessage(obj) && isRpcEventHeaders(obj.headers)
