package main

import (
	"github.com/hx/interop/interop"
	"os"
	"strconv"
	"time"
)

func main() {
	reader, _ := os.OpenFile("a", os.O_RDONLY, 0)
	writer, _ := os.OpenFile("b", os.O_WRONLY|os.O_SYNC, 0)

	server := interop.NewRpcServer(interop.BuildConn(reader, writer))

	server.HandleClassName("countdown", interop.ResponderFunc(func(request interop.Message, _ *interop.MessageBuilder) {
		num, _ := strconv.Atoi(request.GetHeader("ticks"))
		for i := 1; i <= num; i++ {
			time.Sleep(time.Second)
			event := interop.NewRpcMessage("tick")
			event.SetContent(interop.ContentTypeJSON, i)
			server.Send(event)
		}
	}))

	server.Run()
}
