package interop

import (
	"io"
	"sync/atomic"
)

type Pipe struct {
	closed  int32
	err     error
	message chan Message
}

func (p *Pipe) CloseWithError(err error) error {
	if atomic.CompareAndSwapInt32(&p.closed, 0, 1) {
		p.err = err
		close(p.message)
		return nil
	}
	return ErrPipeAlreadyClosed
}

func (p *Pipe) Close() error {
	return p.CloseWithError(io.EOF)
}

func (p *Pipe) Read() (message Message, err error) {
	var ok bool
	message, ok = <-p.message
	if !ok {
		err = p.err
	}
	return
}

func (p *Pipe) Write(message Message) (err error) {
	if atomic.LoadInt32(&p.closed) == 1 {
		return ErrPipeAlreadyClosed
	}
	p.message <- message
	return nil
}

func NewBufferedPipe(bufferSize int) *Pipe {
	return &Pipe{message: make(chan Message, bufferSize)}
}

func NewPipe() *Pipe {
	return NewBufferedPipe(0)
}
