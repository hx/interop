package rpc

import (
	"github.com/hx/interop/interop"
	"io"
	"os"
)

type Server interface {
	interop.Socket

	// Start runs the server, and blocks until it stops.
	Start() error

	// Stop signals the server to stop, and returns immediately. An error will be returned if the server is not running.
	Stop() error
}

func NewStdioServer() (Server, error) {
	return NewServer(os.Stdin, os.Stdout)
}

func NewServer(r io.ReadCloser, w io.WriteCloser) (Server, error) {
	return &SocketServer{
		r: r,
		w: w,
	}, nil
}
