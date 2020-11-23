package interop

import (
	"encoding/json"
	"strconv"
)

type MessageBuilder struct {
	messageBuffer
}

func NewRpcMessage(class string) *MessageBuilder {
	return new(MessageBuilder).SetHeader(MessageClassHeader, class)
}

func DuplicateMessage(message Message) *MessageBuilder {
	return &MessageBuilder{
		messageBuffer: messageBuffer{
			body:    message.Body(),
			headers: message.GetAllHeaders(),
		},
	}
}

func (b *MessageBuilder) SetHeader(name, value string) *MessageBuilder {
	b.headers.Set(name, value)
	return b
}

func (b *MessageBuilder) AddHeader(name, value string) *MessageBuilder {
	b.headers.Add(name, value)
	return b
}

func (b *MessageBuilder) SetBody(body []byte) *MessageBuilder {
	b.body = body
	return b
}

func (b *MessageBuilder) AddError(err error) *MessageBuilder {
	return b.AddHeader(MessageErrorHeader, err.Error())
}

func (b *MessageBuilder) SetJSONBody(data interface{}) (err error) {
	b.setContentType(ContentTypeJSON)
	b.body, err = json.Marshal(data)
	b.setContentLength()
	return
}

func (b *MessageBuilder) SetBinaryBody(data []byte) *MessageBuilder {
	b.setContentType(ContentTypeBinary)
	b.body = make([]byte, len(data))
	copy(b.body, data)
	b.setContentLength()
	return b
}

func (b *MessageBuilder) setContentLength() {
	b.SetHeader(MessageContentLengthHeader, strconv.Itoa(len(b.body)))
}

func (b *MessageBuilder) setContentType(value string) {
	b.SetHeader(MessageContentTypeHeader, value)
}
