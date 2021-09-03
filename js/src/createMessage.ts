import { ContentType, isContentType } from './ContentType'
import { Header } from './Header'
import { Headers, isHeaders } from './Headers'
import { Message } from './Message'

export interface CreateMessageFunc<M extends Message = Message> {
  (): Promise<M>
  (body: Blob): Promise<M>
  (contentType: ContentType, content?: unknown): Promise<M>
  (headers: Headers): Promise<M>
  (headers: Headers, body: Blob): Promise<M>
  (headers: Headers, contentType: ContentType, content?: unknown): Promise<M>
}

const emptyBlob = new Blob([''])

export const createMessageBase = async (...args: unknown[]) => {
  const message: Message = {
    headers: {},
    body:    emptyBlob
  }

  if (isHeaders(args[0])) {
    Object.assign(message.headers, args.shift())
  }

  if (args[0] instanceof Blob) {
    message.body = args[0]
    return message
  }

  if (isContentType(args[0])) {
    const contentType            = args.shift() as ContentType
    message.headers[Header.Type] = contentType.name

    if (args.length > 0) {
      message.body                   = await contentType.marshaler.marshal(args[0])
      message.headers[Header.Length] = message.body.size.toString()
    }
  }

  return message
}

export const createMessage = createMessageBase as CreateMessageFunc
