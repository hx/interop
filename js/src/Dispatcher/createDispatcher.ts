import { Decoder, nullDecoder } from '../createDecoder'
import { Headers } from '../Headers'
import { Message } from '../Message'
import { createDecodingDispatcher } from './createDecodingDispatcher'
import { Dispatcher } from './Dispatcher'

interface CreateDispatcher {
  <HeadersType extends Headers = Headers,
    EventType = Message<HeadersType>>(decoder: Decoder<HeadersType, EventType>): Dispatcher<HeadersType, EventType>

  <HeadersType extends Headers = Headers>(): Dispatcher<HeadersType>
}

export const createDispatcher: CreateDispatcher = (decoder = nullDecoder) => createDecodingDispatcher(decoder)
