import { Headers, isHeaders } from './Headers'
import { isObj } from './utilities'

export interface Message<H extends Headers = Headers> {
  headers: H;
  body: Blob;
}

export const isMessage = (obj: unknown): obj is Message =>
  isObj(obj) && obj.body instanceof Blob && isHeaders(obj.headers)
