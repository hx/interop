type Guard<T> = (obj: unknown) => obj is T

type Extended<A> = Guard<A> & {
  and: <B>(second: Guard<B>) => Extended<A & B>
  or:  <B>(second: Guard<B>) => Extended<A | B>
}

const extend = <A, B>(first: Guard<A>): Extended<A> =>
  Object.assign(first, {
    and: (second: Guard<B>) => extend((obj: unknown): obj is A & B => first(obj) && second(obj)),
    or:  (second: Guard<B>) => extend((obj: unknown): obj is A | B => first(obj) || second(obj))
  }) as Extended<A>

const isNumber  = extend((obj: unknown): obj is number => typeof obj === 'number')
const isString  = extend((obj: unknown): obj is string => typeof obj === 'string')
const isBoolean = extend((obj: unknown): obj is boolean => typeof obj === 'boolean')

const isTrue      = extend((obj: unknown): obj is true => obj === true)
const isFalse     = extend((obj: unknown): obj is false => obj === false)
const isNull      = extend((obj: unknown): obj is null => obj === null)
const isUndefined = extend((obj: unknown): obj is undefined => obj === undefined)

const isFunction = extend((obj: unknown): obj is () => unknown => typeof obj === 'function')

// TODO: make inner return guard type a fixed length array
const isFunctionOf = <L extends number>(length: L) => extend(
  (obj: unknown): obj is () => unknown =>
    isFunction(obj) && obj.length === length
)

const isArray = extend((obj: unknown): obj is unknown[] => Array.isArray(obj))
const isArrayOf = <T>(itemGuard: (item: unknown) => item is T) => extend(
  (obj: unknown): obj is T[] =>
    isArray(obj) && obj.every(itemGuard)
)

const isObject   = extend((obj: unknown): obj is { [x: string]: unknown } =>
  obj !== null &&
  typeof obj === 'object' &&
  obj!.constructor === Object
)
const isObjectOf = <T>(valueGuard: (value: unknown) => value is T) =>  extend(
  (obj: unknown): obj is Record<string, T> =>
    isObject(obj) && Object.values(obj).every(valueGuard)
)

// TODO: spreaders
const isTupleOf = <T extends unknown[]>(...itemGuards: Array<unknown> & {[K in keyof T]: Guard<T[K]>}) => extend(
  (obj: unknown): obj is T =>
    isArray(obj) && obj.length === itemGuards.length && obj.every((item, i) => itemGuards[i](item))
)

export const guards = {
  number:     isNumber,
  string:     isString,
  boolean:    isBoolean,
  true:       isTrue,
  false:      isFalse,
  null:       isNull,
  undefined:  isUndefined,
  array:      isArray,
  arrayOf:    isArrayOf,
  tupleOf:    isTupleOf,
  object:     isObject,
  objectOf:   isObjectOf,
  function:   isFunction,
  functionOf: isFunctionOf,
}
