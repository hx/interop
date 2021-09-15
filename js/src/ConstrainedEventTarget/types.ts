export interface Event {
  type: string
  defaultPrevented?: boolean
}

export interface EventMapBase {
  [key: string]: Event
}

export type Listener<Class extends Event, This = unknown> =
  (this: This, event: Class) => unknown

export type ListenerMap<EventMap extends EventMapBase, This = unknown> =
  {[Type in keyof EventMap]?: Array<[Listener<EventMap[Type], This>, AddEventListenerOptions]>}

export type EventType<EventMap extends EventMapBase, Type extends keyof EventMap> =
  EventMap[Type] & {type: Type}
