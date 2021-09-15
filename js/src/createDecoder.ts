import { ContentType } from './ContentType'
import { ContentTypes } from './ContentTypes'
import { Header } from './Header'
import { Headers } from './Headers'
import { Message } from './Message'

export type Decoder<HeadersType extends Headers = Headers, DecodedType = unknown> = (message: Message<HeadersType>) => Promise<DecodedType>

export const createDecoder = <T, HeadersType extends Headers = Headers>(...contentTypes: ContentType<T, unknown>[]): Decoder<HeadersType, T> =>
  async (message) => {
    const typeName = message.headers[Header.Type]
    const type     = typeof typeName === 'string' && contentTypes.find(t => t.name === typeName)
    if (type) {
      return await type.marshaler.unmarshal(message.body)
    }
    if (typeName) {
      throw new Error(`Cannot decode a message with content type "${typeName}"`)
    }
    throw new Error('Cannot decode a message with no content type')
  }

export const decode = createDecoder(...Object.values(ContentTypes))

export const nullDecoder = async <T extends Message>(message: T) => message
