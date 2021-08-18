package interop

import (
	"context"
	"errors"
	"fmt"
	"io"
	"strings"
	"sync"
	"time"
)

type RpcClient struct {
	bgRunner
	Events   *EventDispatcher
	IDPrefix string
	Timeout  time.Duration
	conn     Conn
	nextId   uint64
	results  map[string]chan Message
	mutex    sync.Mutex
}

func NewRpcClient(conn Conn) (client *RpcClient) {
	client = &RpcClient{
		Events:  new(EventDispatcher),
		conn:    conn,
		results: make(map[string]chan Message),
	}
	client.bgRunner.runner = client
	return
}

func (c *RpcClient) Run() (err error) {
	return ReadAllMessages(c.conn, c.onReceiveMessage)
}

func (c *RpcClient) Send(request Message) (response Message, err error) {
	return c.SendContext(context.Background(), request)
}

func (c *RpcClient) SendContext(ctx context.Context, request Message) (response Message, err error) {
	var (
		idNum        uint64
		idStr        string
		responseChan = make(chan Message, 1)
		cancel       context.CancelFunc
	)

	c.mutex.Lock()
	idNum = c.nextId
	c.nextId += 1
	idStr = fmt.Sprintf("%s%d", c.IDPrefix, idNum)
	c.results[idStr] = responseChan
	c.mutex.Unlock()

	err = c.conn.Write(DuplicateMessage(request).SetHeader(MessageIDHeader, idStr))
	if err != nil {
		c.releaseResponseChan(idStr)
		close(responseChan)
		return
	}

	if c.Timeout > 0 {
		ctx, cancel = context.WithTimeout(ctx, c.Timeout)
	}

	select {
	case response = <-responseChan:
		if response == nil {
			err = io.ErrUnexpectedEOF
		} else {
			errs := response.GetHeaders(MessageErrorHeader)
			if len(errs) > 0 {
				err = errors.New(strings.Join(errs, "; "))
			}
		}
	case <-ctx.Done():
		c.releaseResponseChan(idStr)
		err = ctx.Err()
	}

	if cancel != nil {
		cancel()
	}

	return
}

func (c *RpcClient) Call(class string) (response Message, err error) {
	return c.CallContext(context.Background(), class)
}

func (c *RpcClient) CallContext(ctx context.Context, class string) (response Message, err error) {
	return c.SendContext(ctx, NewRpcMessage(class))
}

func (c *RpcClient) CallWithContent(class string, contentType *ContentType, content interface{}) (response Message, err error) {
	return c.CallWithContentContext(context.Background(), class, contentType, content)
}

func (c *RpcClient) CallWithContentContext(ctx context.Context, class string, contentType *ContentType, content interface{}) (response Message, err error) {
	message := NewRpcMessage(class)
	if err = contentType.EncodeTo(message, content); err != nil {
		return
	}
	return c.SendContext(ctx, message)
}

func (c *RpcClient) onReceiveMessage(message Message) error {
	idStr := message.GetHeader(MessageIDHeader)
	if idStr != "" {
		if responseChan := c.releaseResponseChan(idStr); responseChan != nil {
			responseChan <- message
			close(responseChan)
			return nil
		}
	}
	return c.Events.Dispatch(message)
}

func (c *RpcClient) releaseResponseChan(id string) (channel chan Message) {
	c.mutex.Lock()
	channel = c.results[id]
	delete(c.results, id)
	c.mutex.Unlock()
	return
}
