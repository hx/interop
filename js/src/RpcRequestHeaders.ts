import { Header } from './Header'
import { RpcHeaders, isRpcHeaders } from './RpcHeaders'

export type RpcRequestHeaders = RpcHeaders & { [Header.Class]: string };

export const isRpcRequestHeaders = (obj: unknown): obj is RpcRequestHeaders =>
  isRpcHeaders(obj) && typeof obj['Interop-Rpc-Class'] === 'string'
