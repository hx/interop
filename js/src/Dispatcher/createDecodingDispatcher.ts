import { Decoder } from '../createDecoder'
import { Headers } from '../Headers'
import { Message } from '../Message'
import { Dispatcher } from './Dispatcher'
import { Route } from './types'

export const createDecodingDispatcher = <HeadersType extends Headers = Headers,
  EventType = Message<HeadersType>>(decoder: Decoder<HeadersType, EventType>): Dispatcher<HeadersType, EventType> => {
  const routes: Route<HeadersType, EventType>[] = []

  return {
    async dispatch(message) {
      for (const route of routes) {
        if (route.matcher(message)) {
          route.handler(await decoder(message), message.headers)
          return
        }
      }
    },

    handle(matcher, handler) {
      const route = {matcher, handler}
      routes.push(route)
      return () => routes.splice(routes.indexOf(route), 1)
    }
  }
}
