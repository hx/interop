import { ContentType, isContentType } from '../ContentType'
import { Decoder, createDecoder } from '../createDecoder'
import { RpcEventHeaders } from '../RpcEventHeaders'
import { createEventDispatcher } from './createEventDispatcher'
import { NamedSubscriberSource, NamedSubscribers, createNamedSubscribers } from './createNamedSubscribers'
import { EventDispatcher } from './Dispatcher'

interface CreateRpcEventDispatcher {
  <EventType, NamedEventTypes extends Record<string, EventType> = Record<string, EventType>>(
    decoder: Decoder<RpcEventHeaders, EventType> | ContentType<EventType, unknown>,
    namedSubscriberSource: NamedSubscriberSource<EventType, NamedEventTypes>
  ): EventDispatcher<RpcEventHeaders, EventType> & {namedSubscribers: NamedSubscribers<NamedEventTypes>}

  <EventType>(
    decoder: Decoder<RpcEventHeaders, EventType> | ContentType<EventType, unknown>
  ): EventDispatcher<RpcEventHeaders, EventType>
}

export const createRpcEventDispatcher = (
  function createRpcEventDispatcher<EventType, NamedEventTypes extends Record<string, EventType> = Record<string, EventType>>(
    decoder: Decoder<RpcEventHeaders, EventType> | ContentType<EventType, unknown>,
    namedSubscriberSource?: NamedSubscriberSource<EventType, NamedEventTypes>
  ) {
    const x = isContentType(decoder) ? createDecoder<EventType>(decoder) : decoder
    const dispatcher = createEventDispatcher<RpcEventHeaders, EventType>(x)
    if (namedSubscriberSource) {
      return {
        ...dispatcher,
        namedSubscribers: createNamedSubscribers<EventType, NamedEventTypes>(dispatcher, namedSubscriberSource)
      }
    } else {
      return dispatcher
    }
  }
) as CreateRpcEventDispatcher
