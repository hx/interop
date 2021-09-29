package main

import (
	"fmt"
	"github.com/hx/interop/interop"
	"os"
)

func main() {
	writer, _ := os.OpenFile("a", os.O_WRONLY|os.O_SYNC, 0)
	reader, _ := os.OpenFile("b", os.O_RDONLY, 0)

	client := interop.NewRpcClient(interop.BuildConn(reader, writer))

	client.Events.HandleClassName("tick", interop.HandlerFunc(func(event interop.Message) error {
		i := 0
		interop.ContentTypeJSON.DecodeTo(event, &i)
		fmt.Println("Tick", i)
		if i == 5 {
			writer.Close()
		}
		return nil
	}))

	client.Start()

	client.Send(interop.NewRpcMessage("countdown").AddHeader("ticks", "5"))

	client.Wait()
}
