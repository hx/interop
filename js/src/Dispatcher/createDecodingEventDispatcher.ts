import { Decoder } from '../createDecoder'
import { Message } from '../Message'
import { messageClass } from '../messages'
import { RpcEventHeaders } from '../RpcEventHeaders'
import { createDecodingDispatcher } from './createDecodingDispatcher'
import { EventDispatcher } from './Dispatcher'

export const createDecodingEventDispatcher = <
  HeadersType extends RpcEventHeaders = RpcEventHeaders,
  EventType = Message<HeadersType>
  >(decoder: Decoder<HeadersType, EventType>): EventDispatcher<HeadersType, EventType> => {
  const {handle, ...rest} = createDecodingDispatcher<HeadersType, EventType>(decoder)
  return {
    ...rest,
    handle(matcher, handler) {
      if (typeof matcher === 'string') {
        return handle(m => messageClass(m) === matcher, handler)
      }
      if (matcher instanceof RegExp) {
        return handle(m => matcher.test(messageClass(m)), handler)
      }
      return handle(matcher, handler)
    }
  }
}
