import { ContentTypes } from '../ContentTypes'
import { createRpcRequestMessage } from '../createRpcRequestMessage'
import { isObj } from '../utilities'
import { createRpcEventDispatcher } from './createRpcEventDispatcher'

describe(createRpcEventDispatcher, () => {
  it('handles events based on event class name', async () => {
    interface Person {
      firstName: string
      lastName: string
    }

    type People = Person[]

    const isPerson = (obj: unknown): obj is Person =>
      isObj(obj) &&
      typeof obj.firstName === 'string' &&
      typeof obj.lastName === 'string'

    const isPeople = (obj: unknown): obj is People =>
      Array.isArray(obj) &&
      obj.every(isPerson)

    const {namedSubscribers, dispatch} = createRpcEventDispatcher(ContentTypes.json, {
      onAdd:   ['add', isPerson],
      onLeave: isPeople
    })

    let people: People = []

    const onAdd = namedSubscribers.onAdd(p => people.push(p))
    const onLeave = namedSubscribers.onLeave(p => people = people.filter(x => p.findIndex(y => y.firstName === x.firstName && y.lastName === x.lastName) === -1))

    const me: Person = {firstName: 'Neil', lastName: 'Pearson'}
    const al: Person = {firstName: 'Albert', lastName: 'Einstein'}

    expect(people).toEqual([])
    await dispatch(await createRpcRequestMessage('add', ContentTypes.json, me))
    expect(people).toEqual([me])
    await dispatch(await createRpcRequestMessage('add', ContentTypes.json, al))
    expect(people).toEqual([me, al])
    onAdd()
    await dispatch(await createRpcRequestMessage('add', ContentTypes.json, al))
    await dispatch(await createRpcRequestMessage('onLeave', ContentTypes.json, [me]))
    expect(people).toEqual([al])
    onLeave()
    await dispatch(await createRpcRequestMessage('onLeave', ContentTypes.json, [al]))
    expect(people).toEqual([al])
  })
})
