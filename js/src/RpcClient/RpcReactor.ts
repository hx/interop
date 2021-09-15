import { Conn } from '../Conn'
import { ContentType, NO_CONTENT } from '../ContentType'
import { ContentTypes } from '../ContentTypes'
import { Decoder, decode } from '../createDecoder'
import { createRpcRequestMessage } from '../createRpcRequestMessage'
import { DispatchFunc } from '../Dispatcher/types'
import { Header } from '../Header'
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

interface AllOptions {
  conn: Conn
  encoder: ContentType
  decoder: Decoder<RpcHeaders>
  dispatch: DispatchFunc<RpcEventHeaders>
}

type DefaultOptions = Pick<AllOptions, 'encoder' | 'decoder'>

const defaultOptions: DefaultOptions = {
  encoder: ContentTypes.json,
  decoder: decode
}

type Options = Omit<AllOptions, keyof DefaultOptions> & Partial<AllOptions>

export function createRpcReactor(options: Options): RpcReactor {
  const {conn, encoder, decoder, dispatch} = {...defaultOptions, ...options}

  const calls: Calls = {}
  const error        = run(conn, calls, decoder, dispatch)

  const call = async (name: string, content: unknown = NO_CONTENT) => {
    const request = await (
      content === NO_CONTENT ?
        createRpcRequestMessage(name) :
        createRpcRequestMessage(name, encoder, content)
    )

    const triplet             = newPromiseTriplet<RpcMessage>()
    calls[messageID(request)] = triplet
    conn.write(request)
    const response = await triplet.promise
    const error    = messageError(response)
    if (typeof error === 'string') {
      throw new Error(`error while calling "${name}": ${error || '[blank message]'}`)
    }
    return response.headers[Header.Type] ? decoder(response) : undefined
  }

  let running = true
  error.then(() => running = false)

  return Object.assign(call, {error, get closed() { return !running }})
}

async function run(conn: Conn, calls: Calls, decoder: Decoder<RpcHeaders>, dispatch: DispatchFunc<RpcEventHeaders>) {
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
        await dispatch(message)
      }
    }
  } catch (e) {
    return e
  }
}
