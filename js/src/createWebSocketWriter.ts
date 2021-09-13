import { createBlobFromMessage } from './createBlobFromMessage'
import { Message } from './Message'
import { Writer } from './Writer'

export const createWebSocketWriter = (ws: Pick<WebSocket, 'send'>): Writer =>
  ({write: (message: Message) => ws.send(createBlobFromMessage(message))})
