package interop_test

import (
	. "github.com/hx/interop/interop"
	. "github.com/hx/interop/testing"
	"testing"
)

func TestMessageBuilder_SetJSONBody(t *testing.T) {
	builder := new(MessageBuilder)
	Ok(t, builder.SetJSONBody(map[string]interface{}{"foo": "bar"}))
	Equals(t, "application/json", builder.GetHeader("Content-Type"))
	Equals(t, "13", builder.GetHeader("Content-Length"))
	Equals(t, `{"foo":"bar"}`, string(builder.Body()))
}

func TestMessageBuilder_SetBinaryBody(t *testing.T) {
	builder := new(MessageBuilder)
	Equals(t, builder, builder.SetBinaryBody([]byte("abc")))
	Equals(t, "application/octet-stream", builder.GetHeader("content-type"))
	Equals(t, "3", builder.GetHeader("content-length"))
}

func TestDuplicateMessage_is_clean(t *testing.T) {
	original := NewRpcMessage("foo").SetBinaryBody([]byte("bar"))
	dup := DuplicateMessage(original)
	dup.SetHeader(MessageClassHeader, "baz").SetBinaryBody([]byte("buz"))
	Equals(t, "foo", original.GetHeader(MessageClassHeader))
	Equals(t, "bar", string(original.Body()))
}

func TestNewRpcMessage(t *testing.T) {
	message := NewRpcMessage("foo")
	Equals(t, 1, len(message.GetAllHeaders()))
	Equals(t, "foo", message.GetHeader(MessageClassHeader))
	Equals(t, "", string(message.Body()))
}
