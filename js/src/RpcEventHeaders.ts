import { Header } from './Header'
import { Headers, isHeaders } from './Headers'

export type RpcEventHeaders = Headers & { [Header.Class]: string };

export const isRpcEventHeaders = (obj: unknown): obj is RpcEventHeaders =>
  isHeaders(obj) && typeof obj['Interop-Rpc-Class'] === 'string'
