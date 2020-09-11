package interop

type Message struct {
	Headers Headers
	Body    []byte
}

type Socket interface {
	Handle(pattern string, handler func(message *Message))
	Send(message *Message) error
}
