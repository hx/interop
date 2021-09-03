import { createBlobFromMessage } from './createBlobFromMessage'
import { Message } from './Message'
import { Writer } from './Writer'

export const createWebSocketWriter = (ws: WebSocket): Writer =>
  ({write: (message: Message) => ws.send(createBlobFromMessage(message))})
