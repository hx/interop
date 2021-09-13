import { newExchange } from './Exchange'

describe(newExchange, () => {
  it('represents a double-sided buffer', () => {
    let i = 0
    const {give, take} = newExchange(() => i++)
    expect([give(), take(), take(), give(), give(), give(), give(), take(), give(), take()])
      .toEqual([0, 0, 1, 1, 2, 3, 4, 2, 5, 3])
  })

  it('is inspectable', () => {
    let i = 0
    const {give, take, given, taken} = newExchange(() => i++)
    give(); give(); give()
    expect(take()).toEqual(0)
    expect(given()).toEqual([1,2])
    expect(taken()).toEqual([])
    take(); take(); take()
    expect(given()).toEqual([])
    expect(taken()).toEqual([3])
  })
})
