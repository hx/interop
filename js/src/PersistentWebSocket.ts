import { createConstrainedEventTarget } from './ConstrainedEventTarget'
import { newPromiseTriplet } from './utilities'

export type PersistentWebSocket = Readonly<Pick<WebSocket,
  'send' | 'close' | 'readyState' | 'url' | 'addEventListener' | 'removeEventListener' | 'binaryType'>>

type AllOptions = Pick<WebSocket, 'binaryType'> & {
  /**
   * WebSocket URL. Must start with ws:// or wss://.
   */
  url: typeof WebSocket.prototype.url

  /**
   * Time allowed to establish a connection, in milliseconds.
   */
  connectTimeout: number

  /**
   * Interval to wait before re-attempting connection, in milliseconds.
   */
  retryInterval: number

  /**
   * Number of times to retry connection (excluding initial attempt) before failing permanently. If given as zero, only
   * one attempt will be made to connect, plus one per unexpected disconnection. If negative or unspecified, retries
   * will continue indefinitely.
   */
  maxRetries?: number
}

type DefaultOptions = Pick<AllOptions,
  'connectTimeout' | 'retryInterval' | 'binaryType'>

const defaultOptions: DefaultOptions = {
  connectTimeout: 5000,
  retryInterval:  3000,
  binaryType:     'blob'
}

export const ConnectionClosed   = new Error('connection already closing or closed')
export const MaxRetriesExceeded = new Error('exceeded maximum retries')

export type Options = Partial<AllOptions> & Omit<AllOptions, keyof DefaultOptions>

export const createPersistentWebSocket = (options: Options): PersistentWebSocket => {
  const {connectTimeout, retryInterval, maxRetries, ...opts} = {...defaultOptions, ...options}

  let {promise, resolve, reject} = newPromiseTriplet<WebSocket>()

  let readyState = WebSocket.CONNECTING
  let attempts   = 0

  const {addEventListener, removeEventListener, dispatchEvent} = createConstrainedEventTarget<WebSocketEventMap>()

  const connect = () => {
    const ws      = new WebSocket(opts.url)
    ws.binaryType = opts.binaryType
    ws.onmessage  = dispatchEvent

    const timeout = setTimeout(() => ws.close(1000, 'Connection timeout'), connectTimeout)

    ws.onopen = event => {
      clearTimeout(timeout)
      attempts   = 0
      ws.onerror = dispatchEvent
      readyState = WebSocket.OPEN
      resolve(ws)
      dispatchEvent(event)
    }

    ws.onclose = event => {
      clearTimeout(timeout)
      const open   = readyState === WebSocket.OPEN
      const closed = readyState === WebSocket.CLOSED
      if (open) {
        ({promise, resolve, reject} = newPromiseTriplet<WebSocket>())
      }
      if (open || closed) {
        dispatchEvent(event)
      }
      if (closed) {
        if (!open) {
          reject(ConnectionClosed)
        }
        return
      }
      if (!open && attempts++ === maxRetries) {
        close()
        reject(MaxRetriesExceeded)
        return
      }
      setTimeout(connect, open ? 0 : retryInterval)
      readyState = WebSocket.CONNECTING
    }
  }

  const close = (code?: number, reason?: string) => {
    if (readyState === WebSocket.OPEN) {
      promise.then(ws => ws.close(code, reason))
    }
    readyState = WebSocket.CLOSED
  }

  connect()

  return {
    ...opts,
    addEventListener, removeEventListener,
    get readyState() { return readyState },
    async send(data) {
      if (readyState === WebSocket.CLOSED) {
        throw ConnectionClosed
      }
      (await promise).send(data)
    },
    close
  }
}
