package rpc

import (
	"github.com/hx/interop/interop"
	"io"
)

type SocketServer struct {
	r io.ReadCloser
	w io.WriteCloser
}

func (s *SocketServer) Handle(pattern string, handler func(message *interop.Message)) {
	panic("implement me")
}

func (s *SocketServer) Send(message *interop.Message) error {
	panic("implement me")
}

func (s *SocketServer) Start() error {
	panic("implement me")
}

func (s *SocketServer) Stop() error {
	panic("implement me")
}
