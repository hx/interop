package interop

import (
	"context"
	"fmt"
	"sync"
)

type RpcMultiServer struct {
	RpcDispatcher
	events        MultiWriter
	waitConns     sync.WaitGroup
	waitResponses sync.WaitGroup
}

func (s *RpcMultiServer) Run(conn Conn) (err error) {
	s.waitConns.Add(1)
	s.waitResponses.Add(1)
	unsub := s.events.Subscribe(conn)
	connServer := NewRpcServer(conn)
	connServer.Handle(nil, s)
	err = connServer.Run()
	unsub()
	go func() {
		connServer.WaitClean()
		s.waitResponses.Done()
	}()
	s.waitConns.Done()
	return
}

func (s *RpcMultiServer) Send(event Message) error {
	if event.GetHeader(MessageIDHeader) != "" {
		return ErrEventHasID
	}
	return s.events.Write(event)
}

// Wait blocks while connections are open and readable. Use WaitClean to also wait for all requests to complete.
func (s *RpcMultiServer) Wait() { s.waitConns.Wait() }

func (s *RpcMultiServer) WaitContext(ctx context.Context) error {
	if err := waitContext(ctx, s.Wait); err != nil {
		return fmt.Errorf("did not wait for all connections: %w", err)
	}
	return nil
}

// WaitClean blocks while connections are open, or while RPC requests are running.
func (s *RpcMultiServer) WaitClean() { s.waitResponses.Wait() }

func (s *RpcMultiServer) WaitCleanContext(ctx context.Context) error {
	if err := waitContext(ctx, s.WaitClean); err != nil {
		return fmt.Errorf("did not wait for RPC responses to be sent: %w", err)
	}
	return nil
}
