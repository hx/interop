import { ContentType } from './ContentType'
import { ContentTypes } from './ContentTypes'
import { Header } from './Header'
import { Message } from './Message'

export type Decoder = (message: Message) => Promise<unknown>

export const createDecoder = (...contentTypes: ContentType[]): Decoder =>
  async (message) => {
    const typeName = message.headers[Header.Type]
    const type = typeof typeName === 'string' && contentTypes.find(t => t.name === typeName)
    if (type) {
      return await type.marshaler.unmarshal(message.body)
    }
    return message.body
  }

export const decode = createDecoder(...Object.values(ContentTypes))
