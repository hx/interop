import { isObj } from './utilities'

export interface Marshaler {
  marshal(obj: unknown): Promise<Blob>
  unmarshal(blob: Blob): Promise<unknown>
}

export const isMarshaler = (obj: unknown): obj is Marshaler =>
  isObj(obj) &&
  typeof obj.marshal === 'function' &&
  typeof obj.unmarshal === 'function'
