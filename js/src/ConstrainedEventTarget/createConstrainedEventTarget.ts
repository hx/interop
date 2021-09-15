import { ConstrainedEventTarget } from './ConstrainedEventTarget'
import { EventMapBase, EventType, Listener, ListenerMap } from './types'

export function createConstrainedEventTarget<E, This = unknown, EventMap extends EventMapBase = E & EventMapBase>(receiver?: This) {
  const listeners: ListenerMap<EventMap, This> = {}

  const target: ConstrainedEventTarget<EventMap, This> = {
    addEventListener: <Type extends keyof EventMap>(type: Type, listener: Listener<EventMap[Type], This>, options?: boolean | AddEventListenerOptions): void => {
      (listeners[type] ||= [])!.push([listener, typeof options === 'object' ? options : {capture: options}])
    },

    removeEventListener: <Type extends keyof EventMap>(type: Type, listener: Listener<EventMap[Type], This>, options?: boolean | EventListenerOptions): void => {
      const stack = listeners[type]
      if (!stack) {
        return
      }
      const capture = typeof options === 'object' ? options.capture : options
      for (let i = 0; stack[i]; ++i) {
        const [l, o] = stack[i]
        if (l === listener && !o.capture === !capture) {
          stack.splice(i, 1)
          return
        }
      }
    },

    dispatchEvent: <Type extends keyof EventMap>(event: EventType<EventMap, Type>): boolean => {
      const stack = listeners[event.type]
      if (!stack) {
        return true
      }
      stack.slice().forEach(([l, o]) => {
        if (o.once) {
          target.removeEventListener(event.type, l, o)
        }
        l.call(receiver as This, event as EventMap[Type & string])
      })
      return !event.defaultPrevented
    }
  }

  return target
}
