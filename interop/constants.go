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
	ErrEventHasClass     Error = "event must not have a class"
)
