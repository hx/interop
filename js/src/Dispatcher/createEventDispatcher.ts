import { Decoder, nullDecoder } from '../createDecoder'
import { Message } from '../Message'
import { RpcEventHeaders } from '../RpcEventHeaders'
import { createDecodingEventDispatcher } from './createDecodingEventDispatcher'
import { EventDispatcher } from './Dispatcher'

interface CreateEventDispatcher {
  <HeadersType extends RpcEventHeaders = RpcEventHeaders,
    EventType = Message<HeadersType>>(decoder: Decoder<HeadersType, EventType>): EventDispatcher<HeadersType, EventType>

  <HeadersType extends RpcEventHeaders = RpcEventHeaders>(): EventDispatcher<HeadersType>
}

export const createEventDispatcher: CreateEventDispatcher = (decoder = nullDecoder) =>
  createDecodingEventDispatcher(decoder)
