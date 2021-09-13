import { Conn } from '../Conn'
import { ContentType } from '../ContentType'
import { Decoder } from '../createDecoder'
import { createRpcRequestMessage } from '../createRpcRequestMessage'
import { DispatchFunc } from '../Dispatcher/types'
import { messageError, messageID } from '../messages'
import { RpcEventHeaders } from '../RpcEventHeaders'
import { isRpcEventMessage } from '../RpcEventMessage'
import { RpcHeaders } from '../RpcHeaders'
import { RpcMessage, isRpcMessage } from '../RpcMessage'
import { PromiseTriplet, newPromiseTriplet } from '../utilities'

interface RpcReactor {
  (name: string, content: unknown): Promise<unknown>
  closed: boolean
  error: Promise<unknown>
}

type Calls = Record<string, PromiseTriplet<RpcMessage>>

export function createRpcReactor(
  conn: Conn,
  encoder: ContentType,
  decoder: Decoder<RpcHeaders>,
  dispatcher: DispatchFunc<RpcEventHeaders>
): RpcReactor {
  const calls: Calls = {}
  const call = async (name: string, content: unknown) => {
    const request = await createRpcRequestMessage(name, encoder, content)
    const triplet = newPromiseTriplet<RpcMessage>()
    calls[messageID(request)] = triplet
    conn.write(request)
    const response = await triplet.promise
    const error = messageError(response)
    if (typeof error === 'string') {
      throw new Error(`error while calling "${name}": ${error || '[blank message]'}`)
    }
    return decoder(response)
  }
  const error = run(conn, calls, decoder, dispatcher)

  let running = true
  error.then(() => running = false)

  return Object.assign(call, {error, get closed() { return !running }})
}

async function run(conn: Conn, calls: Calls, decoder: Decoder<RpcHeaders>, dispatcher: DispatchFunc<RpcEventHeaders>) {
  try {
    for (; ;) {
      const message = await conn.read()
      if (isRpcMessage(message)) {
        const id      = messageID(message)
        const triplet = calls[id]
        if (triplet) {
          delete calls[id]
          triplet.resolve(message)
        }
      } else if (isRpcEventMessage(message)) {
        await dispatcher(message)
      }
    }
  } catch (e) {
    return e
  }
}
