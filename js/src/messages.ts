import { Header } from './Header'
import { Headers } from './Headers'
import { Message } from './Message'
import { canonicalizeKey } from './utilities'

export const messageHeader = <T extends Headers, K extends keyof T>(message: Message<T>, header: K & string) =>
  message.headers[header] || (message.headers[canonicalizeKey(header)] as T[K] | undefined)

export const messageID    = <T extends Headers>(message: Message<T>): T[Header.ID]    => messageHeader(message, Header.ID)
export const messageClass = <T extends Headers>(message: Message<T>): T[Header.Class] => messageHeader(message, Header.Class)
export const messageError = <T extends Headers>(message: Message<T>): T[Header.Error] => messageHeader(message, Header.Error)
