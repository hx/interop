package interop

const (
	ContentTypeJSON   = "application/json"
	ContentTypeBinary = "application/octet-stream"
)

const (
	MessageIDHeader            = "Interop-Rpc-Id"
	MessageClassHeader         = "Interop-Rpc-Class"
	MessageErrorHeader         = "Interop-Error"
	MessageContentTypeHeader   = "Content-Type"
	MessageContentLengthHeader = "Content-Length"
)

const HeaderDelimiter = "\n"

type Error string

func (e Error) Error() string {
	return string(e)
}

const (
	ErrPipeAlreadyClosed Error = "pipe already closed"
	ErrEventHasID        Error = "event must not have an ID"
	ErrNotDecodable      Error = "message is not in a decodable format"
)
