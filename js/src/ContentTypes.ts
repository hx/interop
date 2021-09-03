import { ContentType } from './ContentType'
import { jsonMarshaler, nullMarshaler } from './marshalers'

interface DefaultContentTypes {
  json: ContentType
  binary: ContentType
}

export const ContentTypes: DefaultContentTypes = {
  json:   {name: 'application/json', marshaler: jsonMarshaler},
  binary: {name: 'application/octet-stream', marshaler: nullMarshaler}
}
