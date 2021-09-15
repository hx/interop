import { PromiseTriplet, newPromiseTriplet } from '../utilities'
import { Exchange, newExchange } from './Exchange'

export type PromiseExchange<T> = {
  take(): Promise<T>
  give(obj: T): void
} & Omit<Exchange<PromiseTriplet<T>>, 'give' | 'take'>

export function createPromiseExchange<T>(): PromiseExchange<T> {
  const exchange = newExchange(() => newPromiseTriplet<T>())

  return {
    ...exchange,
    give(obj) { exchange.give().resolve(obj) },
    take() { return exchange.take().promise }
  }
}
