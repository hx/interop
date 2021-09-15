import { guards as g } from './guards'

describe('guards', () => {
  it('works on simple types', () => {
    expect(g.string('foo')).toBe(true)
    expect(g.string(123)).toBe(false)
    expect(g.number(123)).toBe(true)
    expect(g.number(false)).toBe(false)
    expect(g.boolean(false)).toBe(true)
    expect(g.boolean(null)).toBe(false)
    expect(g.true(true)).toBe(true)
    expect(g.true(false)).toBe(false)
    expect(g.false(false)).toBe(true)
    expect(g.false(null)).toBe(false)
    expect(g.null(null)).toBe(true)
    expect(g.null(undefined)).toBe(false)
    expect(g.undefined(void 0)).toBe(true)
    expect(g.undefined([])).toBe(false)
    expect(g.array([])).toBe(true)
    expect(g.array({})).toBe(false)
    expect(g.object({})).toBe(true)
    expect(g.object(null)).toBe(false)
    expect(g.object(() => 0)).toBe(false)
    expect(g.function(() => 0)).toBe(true)
    expect(g.function(0)).toBe(false)
    expect(g.unknown(0)).toBe(true)
    expect(g.unknown(undefined)).toBe(true)
    expect(g.unknown(true)).toBe(true)

    expect(g.truthy(true)).toBe(true)
    expect(g.truthy(-1)).toBe(true)
    expect(g.truthy('a')).toBe(true)
    expect(g.truthy({})).toBe(true)
    expect(g.truthy([])).toBe(true)
    expect(g.truthy(false)).toBe(false)
    expect(g.truthy(0)).toBe(false)
    expect(g.truthy('')).toBe(false)
    expect(g.truthy(null)).toBe(false)
    expect(g.truthy(undefined)).toBe(false)
    expect(g.truthy(NaN)).toBe(false)

    expect(g.falsy(true)).toBe(false)
    expect(g.falsy(-1)).toBe(false)
    expect(g.falsy('a')).toBe(false)
    expect(g.falsy({})).toBe(false)
    expect(g.falsy([])).toBe(false)
    expect(g.falsy(false)).toBe(true)
    expect(g.falsy(0)).toBe(true)
    expect(g.falsy('')).toBe(true)
    expect(g.falsy(null)).toBe(true)
    expect(g.falsy(undefined)).toBe(true)
    expect(g.falsy(NaN)).toBe(true)

    expect(g.arrayOf(g.number)([1,2,3])).toBe(true)
    expect(g.arrayOf(g.number)([])).toBe(true)
    expect(g.arrayOf(g.number)([1,2,false])).toBe(false)
    expect(g.arrayOf(g.number)(['a', 5])).toBe(false)
    expect(g.arrayOf(g.number)(5)).toBe(false)
    expect(g.arrayOf(g.number)({a: 1})).toBe(false)

    expect(g.objectOf(g.string)({a: '1', b: '2'})).toBe(true)
    expect(g.objectOf(g.string)({})).toBe(true)
    expect(g.objectOf(g.string)({a: '1', b: 2})).toBe(false)
    expect(g.objectOf(g.string)(['1'])).toBe(false)

    expect(g.tupleOf(g.string, g.number)(['a', 1])).toBe(true)
    expect(g.tupleOf(g.string, g.number)(['a', 1, 0])).toBe(false)
    expect(g.tupleOf(g.string, g.number)(['a'])).toBe(false)
    expect(g.tupleOf(g.string, g.number)([1, 'a'])).toBe(false)
    expect(g.tupleOf(g.string, g.number)(1)).toBe(false)
    expect(g.tupleOf(g.string, g.number)('a')).toBe(false)
    expect(g.tupleOf()([])).toBe(true)
    expect(g.tupleOf()([0])).toBe(false)

    expect(g.functionOf(1)(() => 0)).toBe(false)
    expect(g.functionOf(1)((a: unknown) => a)).toBe(true)
    expect(g.functionOf(1)((a: unknown, b: unknown) => a || b)).toBe(false)

    expect(g('a', null)(null)).toBe(true)
    expect(g('a', null)('a')).toBe(true)
    expect(g('a', null)('b')).toBe(false)
    expect(g('a', null)('undefined')).toBe(false)
  })

  it('eats structs', () => {
    const check = g.struct({
      foo: g.number,
      bar: g.string
    }, {
      required:   ['foo'],
      additional: g.null
    }).optional

    expect(check({foo: 1, bar: 'a'})).toBe(true)
    expect(check({foo: 1, bar: undefined})).toBe(false)
    expect(check({foo: 1})).toBe(true)
    expect(check({bar: 'a'})).toBe(false)
    expect(check({foo: 1, bar: 2})).toBe(false)
    expect(check({foo: 1, baz: 'a'})).toBe(false)
    expect(check({foo: 1, baz: null})).toBe(true)
    expect(check({})).toBe(false)
    expect(check(undefined)).toBe(true)
  })

  it('can combine types', () => {
    const check = g.null.or(g.number).or(g.tupleOf(g.number, g.arrayOf(g.string)))

    expect(check(null)).toBe(true)
    expect(check(0)).toBe(true)
    expect(check([0, []])).toBe(true)
    expect(check([0, ['one']])).toBe(true)
    expect(check([0, ['one', 'two']])).toBe(true)

    expect(check(false)).toBe(false)
    expect(check(undefined)).toBe(false)
    expect(check([0, [1]])).toBe(false)
    expect(check(['0', ['one']])).toBe(false)
    expect(check([0, ['one', null, 'two']])).toBe(false)
  })
})
