import { Headers } from '../Headers'
import { Message } from '../Message'
import { RpcEventHeaders } from '../RpcEventHeaders'
import { DispatchFunc, Handler, Matcher, SubscribeFunc } from './types'

export interface Dispatcher<HeadersType extends Headers = Headers, EventType = Message<HeadersType>> {
  dispatch: DispatchFunc<HeadersType>
  handle: SubscribeFunc<HeadersType, EventType>
}

export type EventDispatcher<HeadersType extends RpcEventHeaders = RpcEventHeaders, EventType = Message<HeadersType>> = Dispatcher<HeadersType, EventType> & {
  handle(matcher: Matcher<HeadersType>, handler: Handler<HeadersType, EventType>): () => void
  handle(eventClassName: string, handler: Handler<HeadersType, EventType>): () => void
  handle(eventClassPattern: RegExp, handler: Handler<HeadersType, EventType>): () => void
}
