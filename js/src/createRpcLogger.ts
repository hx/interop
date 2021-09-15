import { Conn } from './Conn'
import { decode } from './createDecoder'
import { isErrorMessage } from './ErrorMessage'
import { Header } from './Header'
import { Message } from './Message'
import { messageClass, messageError, messageID } from './messages'
import { isRpcEventMessage } from './RpcEventMessage'
import { isRpcMessage } from './RpcMessage'
import { isRpcRequestMessage } from './RpcRequestMessage'

type Kind = 'request' | 'response' | 'event' | 'receive' | 'send' | 'error'
type Level = 'log' | 'warn' | 'info' | 'error' | 'debug'
type Slice1<X> = X extends [unknown, ...infer Y] ? Y : never

const colors: Record<Kind, string> = {
  request:  '#0877ab',
  response: '#017f01',
  event:    '#8a65e8',
  error:    '#ab0101',
  send:     '#a89444',
  receive:  '#b76d16'
}

async function logWithLevel(level: Level, kind: Kind, message: Message, ...args: unknown[]) {
  const a: unknown[] = [
    '%c%s',
    'background: black; font-weight: bold; color: ' + colors[kind],
    kind,
    ...args
  ]
  if (message.headers[Header.Type]) {
    try {
      a.push(await decode(message))
    } catch (e) {
      a.push('error decoding content', e)
    }
  }
  console[level](...a)
}

export function createRpcLogger(conn: Conn, level: Level = 'info'): Conn {
  const log = (...args: Slice1<Parameters<typeof logWithLevel>>) => logWithLevel(level, ...args)

  return {
    async read(): Promise<Message> {
      const message = await conn.read()

      if(isErrorMessage(message)) {
        await log('error', message, messageError(message))
      } else if (isRpcMessage(message)) {
        await log('response', message, messageID(message))
      } else if (isRpcEventMessage(message)) {
        await log('event', message, messageClass(message))
      } else {
        await log('receive', message, message.headers)
      }

      return message
    },

    async write(message: Message) {
      if (isRpcRequestMessage(message)) {
        await log('request', message, messageClass(message), messageID(message))
      } else {
        await log('send', message)
      }

      conn.write(message)
    }
  }
}
