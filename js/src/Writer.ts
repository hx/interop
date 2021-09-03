import { Message } from './Message'

export interface Writer {
  write(message: Message): void
}
