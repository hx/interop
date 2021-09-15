import { createBlobFromMessage } from './createBlobFromMessage'
import { Message } from './Message'
import { Writer } from './Writer'

/*

At present, WebSocket messages sent as blobs do not show up in Chrome's developer tools. Converting them to
ArrayBuffers solves the issue.

See https://bugs.chromium.org/p/chromium/issues/detail?id=962857

 */

export const createWebSocketWriter = (ws: Pick<WebSocket, 'send'>): Writer =>
  ({write: (message: Message) => createBlobFromMessage(message).arrayBuffer().then(a => ws.send(a))})
  // ({write: (message: Message) => ws.send(createBlobFromMessage(message))})
