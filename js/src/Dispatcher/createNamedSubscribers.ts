import { Headers } from '../Headers'
import { messageClass } from '../messages'
import { RpcEventHeaders } from '../RpcEventHeaders'
import { OptionalPrefix, mapToObj, splitPrefix } from '../utilities'
import { Dispatcher } from './Dispatcher'
import { Handler } from './types'

export type NamedSubscribers<Sources extends Record<string, unknown> = Record<string, unknown>, HeadersType extends Headers = Headers> = {
  [Name in keyof Sources]: (handler: (event: Sources[Name], headers: HeadersType) => void) => () => void
}

export type NamedSubscriberSource<EventType = unknown, Sources extends Record<string, EventType> = Record<string, EventType>> = {
  [Name in keyof Sources]: OptionalPrefix<(obj: EventType) => obj is Sources[Name]>
}

export const createNamedSubscribers = <EventType,
  Sources extends Record<string, EventType> = Record<string, EventType>,
  HeadersType extends RpcEventHeaders = RpcEventHeaders,
  DispatcherType extends Dispatcher<HeadersType, EventType> = Dispatcher<HeadersType, EventType>>(
    dispatcher: DispatcherType,
    namedSubscriberSource: NamedSubscriberSource<EventType, Sources>
  ) =>
    mapToObj(Object.keys(namedSubscriberSource), <Name extends keyof Sources>(name: Name) => {
      const [eventName, guard] = splitPrefix(String(name), namedSubscriberSource[name])
      return [
        name,
        (handler: Handler<HeadersType, Sources[Name]>) =>
          dispatcher.handle(m => messageClass(m) === eventName, (obj, headers) => {
            if (!guard(obj)) {
              throw new Error(`Type check failed for event "${eventName}"`)
            }
            handler(obj, headers)
          })
      ]
    })
