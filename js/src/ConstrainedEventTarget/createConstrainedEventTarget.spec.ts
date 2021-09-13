import { createConstrainedEventTarget } from './createConstrainedEventTarget'
import { Event, EventMapBase } from './types'

interface E<T> extends Event {
  detail: T
}

const e = <T>(type: string, detail: T): E<T> => ({type, detail})

describe(createConstrainedEventTarget, () => {
  interface Events extends EventMapBase {
    append: E<string>
    remove: E<string>
  }

  const events = createConstrainedEventTarget<Events>()
  const result: string[] = []

  beforeEach(() => {
    Object.assign(events, createConstrainedEventTarget())
    result.length = 0
  })

  it('respects the "once" option in addEventListener', () => {
    events.addEventListener('append', e => result.push(e.detail), {once: true})
    events.dispatchEvent(e('append', 'foo'))
    events.dispatchEvent(e('append', 'bar'))
    expect(result).toEqual(['foo'])
    events.addEventListener('append', e => result.push(e.detail))
    events.dispatchEvent(e('append', 'foo'))
    events.dispatchEvent(e('append', 'bar'))
    expect(result).toEqual(['foo', 'foo', 'bar'])
  })
})
