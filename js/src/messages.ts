import { Header } from './Header'
import { Headers } from './Headers'
import { Message } from './Message'

export const messageID = <T extends Headers>(message: Message<T>): T[Header.ID] => message.headers[Header.ID]
export const messageClass = <T extends Headers>(message: Message<T>): T[Header.Class] => message.headers[Header.Class]
export const messageError = (message: Message) => message.headers[Header.Error]
