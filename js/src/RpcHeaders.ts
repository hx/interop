import { Header } from './Header'
import { Headers, isHeaders } from './Headers'

export type RpcHeaders = Headers & { [Header.ID]: string };

export const isRpcHeaders = (obj: unknown): obj is RpcHeaders =>
  isHeaders(obj) && typeof obj['Interop-Rpc-Id'] === 'string'
