import { Headers } from '../Headers'
import { Message } from '../Message'

export type Handler<HeadersType extends Headers = Headers, EventType = Message<HeadersType>> =
  (event: EventType, headers: HeadersType) => void

export type Matcher<HeadersType extends Headers = Headers> =
  (message: Message<HeadersType>) => boolean

export interface Route<HeadersType extends Headers = Headers, EventType = Message<HeadersType>> {
  matcher: Matcher<HeadersType>
  handler: Handler<HeadersType, EventType>
}

export type DispatchFunc<HeadersType extends Headers = Headers> =
  (message: Message<HeadersType>) => Promise<void>

export type SubscribeFunc<HeadersType extends Headers = Headers, EventType = Message<HeadersType>> =
  (matcher: Matcher<HeadersType>, handler: Handler<HeadersType, EventType>) => () => void
