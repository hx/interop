package interop_test

import (
	. "github.com/hx/interop/interop"
	. "github.com/hx/interop/testing"
	"io"
	"testing"
)

type Env struct {
	outbound  *Pipe
	inbound   *Pipe
	client    *RpcClient
	server    *RpcServer
	clientErr chan error
	serverErr chan error
}

func NewEnv() *Env {
	env := &Env{
		outbound:  NewPipe(),
		inbound:   NewPipe(),
		clientErr: make(chan error, 1),
		serverErr: make(chan error, 1),
	}
	env.client = NewRpcClient(CombineReaderWriter(env.inbound, env.outbound))
	env.server = NewRpcServer(CombineReaderWriter(env.outbound, env.inbound))
	go func() { env.clientErr <- env.client.Run() }()
	go func() { env.serverErr <- env.server.Run() }()
	return env
}

func TestServer_Sanity(t *testing.T) {
	env := NewEnv()
	var events []Message
	env.client.Events.Handle(nil, HandlerFunc(func(message Message) error {
		events = append(events, message)
		return nil
	}))
	env.server.HandleClassName("ping", ResponderFunc(func(request Message, response *MessageBuilder) {
		Equals(t, "ping", request.GetHeader(MessageClassHeader))
		Equals(t, "0", request.GetHeader(MessageIDHeader))
		Ok(t, env.server.Send(new(MessageBuilder).SetBinaryBody([]byte("pinged"))))
		response.SetBody([]byte("pong"))
	}))
	Equals(t, 0, len(events))
	response, err := env.client.Call("ping")
	Equals(t, 1, len(events))
	Equals(t, "pinged", string(events[0].Body()))
	Ok(t, err)
	Equals(t, "pong", string(response.Body()))
	Ok(t, env.outbound.Close())
	Equals(t, io.EOF, <-env.serverErr)
	Ok(t, env.inbound.Close())
	Equals(t, io.EOF, <-env.clientErr)
}
