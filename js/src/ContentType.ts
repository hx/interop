import { Marshaler, isMarshaler } from './Marshaler'
import { isObj } from './utilities'

export interface ContentType<Output = unknown, Input = Output> {
  name: string
  marshaler: Marshaler<Output, Input>
}

export const isContentType = (obj: unknown): obj is ContentType =>
  isObj(obj) &&
  typeof obj.name === 'string' &&
  isMarshaler(obj.marshaler)

export const NO_CONTENT = {}
