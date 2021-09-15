import { isObj } from './utilities'

export interface Marshaler<Output = unknown, Input = Output> {
  marshal(obj: Input | Output): Promise<Blob>
  unmarshal(blob: Blob): Promise<Output>
}

export const isMarshaler = (obj: unknown): obj is Marshaler =>
  isObj(obj) &&
  typeof obj.marshal === 'function' &&
  typeof obj.unmarshal === 'function'
