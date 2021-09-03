package interop

type RpcMultiServer struct {
	RpcDispatcher
	events MultiWriter
}

func (s *RpcMultiServer) Run(conn Conn) (err error) {
	unsub := s.events.Subscribe(conn)
	connServer := NewRpcServer(conn)
	connServer.Handle(nil, s)
	err = connServer.Run()
	unsub()
	return
}

func (s *RpcMultiServer) Send(event Message) error {
	if event.GetHeader(MessageIDHeader) != "" {
		return ErrEventHasID
	}
	return s.events.Write(event)
}
