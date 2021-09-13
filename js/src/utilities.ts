type obj = Record<string | number | symbol, unknown>;

export const isObj = (x: unknown): x is obj => x !== null && typeof x === 'object'

export const mapToObj = <K extends keyof never, V, I>(
  array: Readonly<I[]>,
  callback: (o: I, i: number, a: Readonly<I[]>) => [K, V],
): Record<K, V> => Object.fromEntries(array.map(callback)) as Record<K, V>

export interface PromiseTriplet<T> {
  promise: Promise<T>
  resolve: (result: T | PromiseLike<T>) => void
  reject: (error: unknown) => void
}

export const newPromiseTriplet = <T>() => {
  let resolve, reject
  const promise = new Promise<T>((...a) => [resolve, reject] = a)
  return {promise, resolve, reject} as unknown as PromiseTriplet<T>
}

export type OptionalPrefix<T> = T | [string, T]

export const splitPrefix = <T>(defaultPrefix: string, pair: OptionalPrefix<T>): [string, T] => {
  if (Array.isArray(pair)) {
    return pair
  } else {
    return [defaultPrefix, pair]
  }
}
