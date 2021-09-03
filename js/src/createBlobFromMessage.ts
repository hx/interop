import { ContentTypes } from './ContentTypes'
import { Message } from './Message'

export const createBlobFromMessage = (message: Message): Blob =>
  new Blob([
    ...Object.entries(message.headers).map(([k, v]) => `${k}: ${v}\n`),
    '\n',
    message.body,
    '\n'
  ], {
    type: ContentTypes.binary.name
  })
