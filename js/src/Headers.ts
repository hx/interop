import { isObj } from './utilities'
import { Header } from './Header'

export type Headers = { [key in Header]?: string } & Record<string, string>

export const isHeaders = (obj: unknown): obj is Headers =>
  isObj(obj) && Object.keys(obj).every(k => typeof obj[k] === 'string')
