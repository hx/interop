import { EventMapBase, EventType, Listener } from './types'

export interface ConstrainedEventTarget<EventMap extends EventMapBase, This = unknown> {
  addEventListener: <Type extends keyof EventMap>(
    type: Type,
    listener: Listener<EventMap[Type], This>,
    options?: boolean | AddEventListenerOptions
  ) => void
  removeEventListener: <Type extends keyof EventMap>(
    type: Type,
    listener: Listener<EventMap[Type], This>,
    options?: boolean | EventListenerOptions
  ) => void
  dispatchEvent: <Type extends keyof EventMap>(
    event: EventType<EventMap, Type>
  ) => boolean
}
