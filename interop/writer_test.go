package interop_test

import (
	"bytes"
	. "github.com/hx/interop/interop"
	. "github.com/hx/interop/testing"
	"testing"
)

func TestWriteMessage(t *testing.T) {
	builder := new(MessageBuilder).
		SetHeader("foo", "bar").
		AddHeader("foo", "baz").
		SetBody([]byte("foobar!"))
	expected := `
Foo: bar
Foo: baz

foobar!
`[1:]
	actual := new(bytes.Buffer)

	n, err := WriteMessage(builder, actual)
	Ok(t, err)
	Equals(t, int64(len(expected)), n)
	Equals(t, expected, actual.String())
}

func TestWriter_Write(t *testing.T) {
	message := NewRpcMessage("foo")
	Ok(t, message.SetContent(ContentTypeBinary, []byte("bar")))
	expected := `
Interop-Rpc-Class: foo
Content-Type: application/octet-stream
Content-Length: 3

bar
`[1:]
	actual := new(bytes.Buffer)
	writer := NewWriter(actual)
	Ok(t, writer.Write(message))
	Equals(t, expected, actual.String())
}
