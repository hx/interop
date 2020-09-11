package rpc

import (
	"io"
	"os/exec"
)

type Request interface {
	ID() string
	Command() string
	Body() interface{}
}

type Response interface {
	Request() Request
	Error() error
	Body() interface{}
}

type Client interface {
	Send(request Request, handler func(response Response)) error
	Disconnect() error
}

func NewClient(r io.ReadCloser, w io.WriteCloser) (Client, error) {
	panic("implement me")
}

func NewProcessClient(command *exec.Cmd) (Client, error) {
	panic("implement me")
}
