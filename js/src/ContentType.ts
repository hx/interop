import { Marshaler, isMarshaler } from './Marshaler'
import { isObj } from './utilities'

export interface ContentType {
  name: string
  marshaler: Marshaler
}

export const isContentType = (obj: unknown): obj is ContentType =>
  isObj(obj) &&
  typeof obj.name === 'string' &&
  isMarshaler(obj.marshaler)
