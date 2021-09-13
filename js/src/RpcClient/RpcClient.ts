import { Dispatcher } from '../Dispatcher'
import { RpcMethods, SignaturesBase } from './createRpcMethods'

export type RpcClient<Signatures extends SignaturesBase, DispatcherType extends Dispatcher> =
  Omit<DispatcherType, 'dispatch'> &
  RpcMethods<Signatures>
