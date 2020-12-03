package interop

import "fmt"

type RpcServer struct {
	RpcDispatcher
	conn Conn
	err  chan error
}

func NewRpcServer(conn Conn) *RpcServer {
	return &RpcServer{
		conn: conn,
	}
}

func (s *RpcServer) Run() (err error) {
	s.err = make(chan error, 2)
	var req Message
	for {
		req, err = s.conn.Read()
		if err != nil {
			s.err <- err
			break
		}
		go func() {
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
			}()
			s.Dispatch(req, res)
		}()
	}
	return <-s.err
}

func (s *RpcServer) Send(event Message) error {
	if event.GetHeader(MessageIDHeader) != "" {
		return ErrEventHasID
	}
	return s.conn.Write(event)
}
