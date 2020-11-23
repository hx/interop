package interop

type Message interface {
	GetHeader(name string) string
	GetHeaders(name string) []string
	GetAllHeaders() []Header
	Body() []byte
}

type messageBuffer struct {
	headers Headers
	body    []byte
}

func (m *messageBuffer) GetHeaders(name string) []string {
	return m.headers.GetAll(name)
}

func (m *messageBuffer) GetAllHeaders() []Header {
	return m.headers
}

func (m *messageBuffer) Body() []byte {
	return m.body
}

func (m *messageBuffer) GetHeader(name string) string {
	return m.headers.Get(name)
}
