import { ContentType } from './ContentType'
import { Marshaler } from './Marshaler'
import { jsonMarshaler, nullMarshaler } from './marshalers'

const make = <Output, Input>(name: string, marshaler: Marshaler<Output, Input>): ContentType<Output, Input> =>
  ({name, marshaler})

export const ContentTypes = {
  json:   make('application/json', jsonMarshaler),
  binary: make('application/octet-stream', nullMarshaler)
}
