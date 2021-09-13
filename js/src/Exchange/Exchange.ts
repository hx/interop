export interface Exchange<T> {
  take(): T
  give(): T
  taken(): T[]
  given(): T[]
}

export function newExchange <T>(factory: () => T): Exchange<T> {
  const buffer: T[] = []
  let side = false

  const set = (fromSide: boolean) => () => {
    if (buffer.length > 0 && side === fromSide) {
      return buffer.shift()!
    }
    side = !fromSide
    const n = factory()
    buffer.push(n)
    return n
  }

  const get = (fromSide: boolean) => () => side === fromSide ? [] : buffer.slice()

  return {
    take: set(true),
    give: set(false),
    taken: get(true),
    given: get(false)
  }
}
