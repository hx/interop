import { isObj, mapToObj } from './utilities'
import { Header } from './Header'

export type Headers = { [key in Header]?: string };

const allHeaders: Record<string, boolean> = mapToObj(
  [Header.ID, Header.Type, Header.Class, Header.Error, Header.Length],
  h => [h, true],
)

export const isHeaders = (obj: unknown): obj is Headers =>
  isObj(obj) && Object.keys(obj).every(k => allHeaders[k] && typeof obj[k] === 'string')
