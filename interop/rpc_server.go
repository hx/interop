package interop

import (
	"context"
	"fmt"
	"sync"
)

type RpcServer struct {
	RpcDispatcher
	bgRunner
	conn Conn
	err  chan error
	wait sync.WaitGroup
}

func NewRpcServer(conn Conn) (server *RpcServer) {
	server = &RpcServer{
		conn: conn,
	}
	server.bgRunner.runner = server
	return
}

func (s *RpcServer) Run() (err error) {
	s.err = make(chan error, 2)
	var req Message
	ctx, cancel := context.WithCancel(context.Background())
	for {
		req, err = s.conn.Read()
		if err != nil {
			s.err <- err
			break
		}
		s.wait.Add(1)
		go func(req Message) {
			res := new(MessageBuilder)
			defer func() {
				ex := recover()
				res.SetHeader(MessageIDHeader, req.GetHeader(MessageIDHeader))
				if ex != nil {
					res.AddError(fmt.Errorf("panic: %v", ex))
				}
				if err := s.conn.Write(res); err != nil {
					s.err <- err
				}
				s.wait.Done()
			}()
			s.Respond(ctx, req, res)
		}(req)
	}
	err = <-s.err
	cancel()
	return
}

func (s *RpcServer) Send(event Message) error {
	if event.GetHeader(MessageIDHeader) != "" {
		return ErrEventHasID
	}
	return s.conn.Write(event)
}

// WaitClean blocks while RPC requests are running, even after Run has returned.
func (s *RpcServer) WaitClean() { s.wait.Wait() }

func (s *RpcServer) WaitCleanContext(ctx context.Context) error {
	if err := waitContext(ctx, s.WaitClean); err != nil {
		return fmt.Errorf("did not wait for RPC responses to be sent: %w", err)
	}
	return nil

}

func waitContext(ctx context.Context, wait func()) error {
	done := make(chan struct{})
	go func() {
		wait()
		close(done)
	}()
	select {
	case <-done:
		return nil
	case <-ctx.Done():
		return ctx.Err()
	}
}
