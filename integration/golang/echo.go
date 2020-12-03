package main

import (
	"encoding/json"
	"fmt"
	. "github.com/hx/interop/interop"
	"io"
	"os"
	"os/exec"
	"strings"
	"sync"
)

type Echo struct {
	sequence  []interface{}
	main      bool
	layerName string
	mutex     sync.Mutex
	client    *RpcClient
}

func (e *Echo) rec(messages ...string) {
	e.mutex.Lock()
	msg := e.layerName + " " + strings.Join(messages, " ")
	e.sequence = append(e.sequence, msg)
	_, err := fmt.Fprintln(os.Stderr, msg)
	check(err)
	e.mutex.Unlock()
}

func (e *Echo) run() {
	e.rec("calling")
	resp, err := e.client.CallWithJSON("dig", []string{e.layerName + " called"})
	check(err)
	var body []interface{}
	check(Decode(resp, &body))
	e.mutex.Lock()
	e.sequence = append(e.sequence, body)
	e.mutex.Unlock()
}

func main() {
	var (
		e          = &Echo{}
		args       = os.Args[1:]
		upstream   Conn
		closer     io.Closer
		clientDone = make(chan struct{})
	)

	if args[0] == "--main" {
		args = args[1:]
		e.main = true
	}

	e.layerName = args[0]
	args = args[1:]

	if len(args) > 0 {
		cmd := exec.Command(args[0], args[1:]...)
		cmd.Stderr = os.Stderr
		in, err := cmd.StdinPipe()
		check(err)
		out, err := cmd.StdoutPipe()
		check(err)
		upstream = BuildConn(out, in)
		closer = in
		check(cmd.Start())
	} else {
		pipe := NewBufferedPipe(1)
		upstream = pipe
		closer = pipe
	}

	e.client = NewRpcClient(upstream)
	e.client.Events.HandleClassName("finishing", HandlerFunc(func(event Message) error {
		e.rec("handle", event.GetHeader("layer-name"))
		return nil
	}))

	go func() {
		check(e.client.Run())
		clientDone <- struct{}{}
	}()

	e.rec("init")

	if e.main {
		e.run()
	} else {
		server := NewRpcServer(StdioConn())
		server.HandleClassName("dig", ResponderFunc(func(request Message, response *MessageBuilder) {
			var seq []interface{}
			check(Decode(request, &seq))
			e.mutex.Lock()
			e.sequence = append(e.sequence, seq...)
			e.mutex.Unlock()
			e.rec("dig")
			e.run()
			e.rec("trigger")
			event := NewRpcMessage("finishing")
			event.SetHeader("layer-name", e.layerName)
			check(server.Send(event))
			e.rec("done")
			e.mutex.Lock()
			check(response.SetJSONBody(e.sequence))
			e.mutex.Unlock()
		}))
		check(server.Run())
	}

	check(closer.Close())
	<-clientDone

	if e.main {
		j, err := json.MarshalIndent(e.sequence, "", "  ")
		check(err)
		fmt.Println(string(j))
	}
}

func check(err error) {
	if err != nil && err != io.EOF {
		panic(err)
	}
}
