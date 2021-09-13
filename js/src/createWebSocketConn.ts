import { Conn } from './Conn'
import { createWebSocketWriter } from './createWebSocketWriter'
import { createPromiseExchange } from './Exchange/PromiseExchange'
import { Message } from './Message'
import { parseMessageFromBlob } from './parseMessageFromBlob'
import {
  ConnectionClosed,
  Options as PersistentWebSocketOptions,
  createPersistentWebSocket
} from './PersistentWebSocket'
import { isObj } from './utilities'

export const UnexpectedNonBinary = new Error('received unexpected non-binary message')

type PartialWebSocket = Pick<WebSocket, 'send' | 'addEventListener' | 'readyState'>

const isPartialWebSocket = (obj: unknown): obj is PartialWebSocket =>
  isObj(obj) &&
  typeof obj.send === 'function' &&
  typeof obj.addEventListener === 'function'

interface CreateWebSocketConn {
  (websocket: PartialWebSocket): Conn
  (url: string): Conn
  (options: PersistentWebSocketOptions): Conn
}

export const createWebSocketConn: CreateWebSocketConn = (arg: PartialWebSocket | string | PersistentWebSocketOptions): Conn => {
  const ws = isPartialWebSocket(arg) ? arg :
    typeof arg === 'string' ? createPersistentWebSocket({url: arg}) :
      createPersistentWebSocket(arg)

  const exchange = createPromiseExchange<Message>()
  let closed = false

  const read = async () => {
    if (closed) {
      throw ConnectionClosed
    }
    return await exchange.take()
  }

  ws.addEventListener('message', async (e) => {
    if (!(e.data instanceof Blob)) {
      throw UnexpectedNonBinary
    }

    exchange.give(await parseMessageFromBlob(e.data))
  })

  ws.addEventListener('close', () => {
    if (ws.readyState === WebSocket.CLOSED) {
      closed = true
      exchange.taken().forEach(t => t.reject(ConnectionClosed))
    }
  })

  return {read, ...createWebSocketWriter(ws)}
}
