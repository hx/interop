package interop

import "encoding/json"

// Decode the given message into the given target. If the message is not in one of the known decodable formats,
// ErrNotDecodable will be returned.
func Decode(message Message, target interface{}) error {
	switch message.GetHeader(MessageContentTypeHeader) {
	case ContentTypeJSON:
		return json.Unmarshal(message.Body(), target)
	}
	return ErrNotDecodable
}
