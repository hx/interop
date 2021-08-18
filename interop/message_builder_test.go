package interop_test

import (
	. "github.com/hx/interop/interop"
	. "github.com/hx/interop/testing"
	"testing"
)

func TestMessageBuilder_SetContent(t *testing.T) {
	builder := new(MessageBuilder)
	Ok(t, builder.SetContent(ContentTypeJSON, map[string]interface{}{"foo": "bar"}))
	Equals(t, "application/json", builder.GetHeader("Content-Type"))
	Equals(t, "13", builder.GetHeader("Content-Length"))
	Equals(t, `{"foo":"bar"}`, string(builder.Body()))
}

func TestDuplicateMessage_is_clean(t *testing.T) {
	original := NewRpcMessage("foo").SetBody([]byte("bar"))
	dup := DuplicateMessage(original)
	dup.SetHeader(MessageClassHeader, "baz").SetBody([]byte("buz"))
	Equals(t, "foo", original.GetHeader(MessageClassHeader))
	Equals(t, "bar", string(original.Body()))
}

func TestNewRpcMessage(t *testing.T) {
	message := NewRpcMessage("foo")
	Equals(t, 1, len(message.GetAllHeaders()))
	Equals(t, "foo", message.GetHeader(MessageClassHeader))
	Equals(t, "", string(message.Body()))
}
