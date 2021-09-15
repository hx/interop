// TODO: move these to their own package @hxjs/guards

type Guard<T> = (obj: unknown) => obj is T

type Extended<A> = Guard<A> & {
  and: <B>(second: Guard<B>) => Extended<A & B>
  or:  <B>(second: Guard<B>) => Extended<A | B>
  optional: Extended<A | undefined>
}

type Falsy = 0 | typeof NaN | '' | false | null | void | undefined

const extend = <A>(first: Guard<A>): Extended<A> =>
  Object.assign(first, {
    and: <B>(second: Guard<B>) => extend((obj: unknown): obj is A & B => first(obj) && second(obj)),
    or:  <B>(second: Guard<B>) => extend((obj: unknown): obj is A | B => first(obj) || second(obj)),
    optional: first(undefined) ? first : extend((obj: unknown): obj is A | undefined => obj === undefined || first(obj))
  }) as Extended<A>

const isNever     = extend((obj: unknown): obj is never => false)
const isUnknown   = extend((obj: unknown): obj is unknown => true)
const isUndefined = extend((obj: unknown): obj is undefined => obj === undefined)
const isNull      = extend((obj: unknown): obj is null => obj === null)
const isTrue      = extend((obj: unknown): obj is true => obj === true)
const isFalse     = extend((obj: unknown): obj is false => obj === false)
const isNumber    = extend((obj: unknown): obj is number => typeof obj === 'number')
const isString    = extend((obj: unknown): obj is string => typeof obj === 'string')
const isBoolean   = extend((obj: unknown): obj is boolean => typeof obj === 'boolean')
const isFunction  = extend((obj: unknown): obj is () => unknown => typeof obj === 'function')
const isArray     = extend((obj: unknown): obj is unknown[] => Array.isArray(obj))
const isFalsy     = extend((obj: unknown): obj is Falsy => !obj)
const isTruthy    = extend(<T>(obj: T | Falsy): obj is T => !!obj)

// TODO: make inner return predicate type a fixed length array
const isFunctionOf = <L extends number>(length: L) => extend(
  (obj: unknown): obj is () => unknown =>
    isFunction(obj) && obj.length === length
)

const isArrayOf = <T>(itemGuard: (item: unknown) => item is T) => extend(
  (obj: unknown): obj is T[] =>
    isArray(obj) && obj.every(itemGuard)
)

const isObject   = extend((obj: unknown): obj is { [x: string]: unknown } =>
  obj !== null &&
  typeof obj === 'object' &&
  obj!.constructor === Object
)
const isObjectOf = <T>(valueGuard: (value: unknown) => value is T) => extend(
  (obj: unknown): obj is Record<string, T> =>
    isObject(obj) && Object.values(obj).every(valueGuard)
)

// TODO: spreaders
const isTupleOf = <T extends unknown[]>(...itemGuards: Array<unknown> & { [K in keyof T]: Guard<T[K]> }) => extend(
  (obj: unknown): obj is T =>
    isArray(obj) && obj.length === itemGuards.length && obj.every((item, i) => itemGuards[i](item))
)

const anyOf = <T>(...literals: T[]) => extend(
  (obj: unknown): obj is T =>
    literals.indexOf(obj as T) !== -1
)

interface StructOptions<T> {
  required: Array<keyof T> | true
  additional: Guard<unknown>
}

const defaultStructOptions = {
  required:   [],
  additional: isUnknown
}

const isStruct = <T>(members: { [K in keyof T]: Guard<T[K]> }, options: Partial<StructOptions<T>> = {}) => {
  const {required, additional} = {...defaultStructOptions, ...options}
  const requiredKeys           = isArray(required) ? required : Object.keys(members) as Array<keyof T>

  return extend(
    (obj: unknown): obj is T =>
      isObject(obj) &&
      Object.keys(obj).every(k => k in members ? members[k as keyof T](obj[k]) : additional(obj[k])) &&
      requiredKeys.every(k => k in obj)
  )
}

export const guards = Object.assign(anyOf, {
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
  struct:     isStruct,
  unknown:    isUnknown,
  never:      isNever,
  falsy:      isFalsy,
  truthy:     isTruthy
})
