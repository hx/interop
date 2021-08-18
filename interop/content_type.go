package interop

import "github.com/hx/interop/interop/encoding"

type ContentType struct {
	encoding.Marshaler
	Name string
}

func (c *ContentType) Encode(value interface{}) (Message, error) {
	builder := new(MessageBuilder)
	if err := c.EncodeTo(builder, value); err == nil {
		return builder, nil
	} else {
		return nil, err
	}
}

func (c *ContentType) EncodeTo(builder *MessageBuilder, value interface{}) error {
	if body, err := c.Marshal(value); err == nil {
		builder.SetBody(body)
		builder.setContentType(c.Name)
		builder.setContentLength()
		return nil
	} else {
		return err
	}
}

func (c *ContentType) Decode(m Message) (interface{}, error)   { return c.Unmarshal(m.Body()) }
func (c *ContentType) DecodeTo(m Message, t interface{}) error { return c.UnmarshalTo(m.Body(), t) }
