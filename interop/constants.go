package interop

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
	ErrAlreadyClosed    Error = "already closed"
	ErrEventHasID       Error = "event must not have an ID"
	ErrUnrecognisedType Error = "unrecognised content type"
)
