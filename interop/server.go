package interop

import "io"

type Server struct {
}

func (s Server) Handle(pattern string, handler func(message *Message)) {
	panic("implement me")
}

func (s Server) Send(message *Message) error {
	panic("implement me")
}

func NewServer(r io.ReadCloser, w io.WriteCloser) Socket {
	server := &Server{}
	pipe := &serverPipe{server}
	go io.Copy(pipe, r)
	go io.Copy(w, pipe)
	return server
}

type serverPipe struct {
	server *Server
}

func (sp *serverPipe) Read(p []byte) (n int, err error) {
	panic("not yet")
}

func (sp *serverPipe) Write(p []byte) (n int, err error) {
	panic("not yet")
}
