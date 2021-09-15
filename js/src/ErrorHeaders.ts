import { Header } from './Header'
import { Headers, isHeaders } from './Headers'

export type ErrorHeaders = Headers & { [Header.Error]: string };

export const isErrorHeaders = (obj: unknown): obj is ErrorHeaders =>
  isHeaders(obj) && typeof obj['Interop-Error'] === 'string'
