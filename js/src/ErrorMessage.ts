import { Message, isMessage } from './Message'
import { ErrorHeaders, isErrorHeaders } from './ErrorHeaders'

export type ErrorMessage = Message<ErrorHeaders>

export const isErrorMessage = (obj: unknown): obj is ErrorMessage =>
  isMessage(obj) && isErrorHeaders(obj.headers)
