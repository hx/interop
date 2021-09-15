import { Message } from './Message'

export interface Reader {
  read(): Promise<Message>
}
