package interop

// An Interceptor receives a Message and a Writer, and should write a modified version of the message to the writer.
// Messages can be removed from a message bus by skipping Write() calls. Multiple writes within a single intercept are
// permitted. Writing the message once, without modification, to the writer, is equivalent to having no interceptor.
type Interceptor func(message Message, writer Writer) error

type readInterceptor struct {
	reader      Reader
	interceptor Interceptor
	pipe        *Pipe
}

func NewReadInterceptor(reader Reader, interceptor Interceptor) Reader {
	if interceptor == nil {
		panic("interceptor function must not be nil")
	}
	r := &readInterceptor{
		reader:      reader,
		interceptor: interceptor,
		pipe:        NewPipe(),
	}
	go r.relay()
	return r
}

func (r *readInterceptor) Read() (message Message, err error) {
	return r.pipe.Read()
}

func (r *readInterceptor) relay() {
	err := ReadAllMessages(r.reader, func(message Message) error {
		return r.interceptor(message, r.pipe)
	})
	_ = r.pipe.CloseWithError(err)
}

type writeInterceptor struct {
	writer      Writer
	interceptor Interceptor
}

func NewWriteInterceptor(writer Writer, interceptor Interceptor) Writer {
	if interceptor == nil {
		panic("interceptor function must not be nil")
	}
	return &writeInterceptor{writer, interceptor}
}

func (w *writeInterceptor) Write(message Message) (err error) {
	return w.interceptor(message, w.writer)
}

// Wrap wraps a Conn with optional read (inbound) and write (outbound) interceptors, returning a new Conn.
func Wrap(conn Conn, readInterceptor, writeInterceptor Interceptor) Conn {
	var (
		reader Reader = conn
		writer Writer = conn
	)
	if readInterceptor != nil {
		reader = NewReadInterceptor(reader, readInterceptor)
	}
	if writeInterceptor != nil {
		writer = NewWriteInterceptor(writer, writeInterceptor)
	}
	return CombineReaderWriter(reader, writer)
}
