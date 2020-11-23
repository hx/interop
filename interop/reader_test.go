package interop_test

import (
	"bytes"
	"github.com/hx/interop/interop"
	. "github.com/hx/interop/testing"
	"io"
	"testing"
)

func TestMessageReader_ReadMessage(t *testing.T) {
	src := `Content-Length: 5

abcde
fg`

	buf := bytes.NewBuffer([]byte(src))
	scanner := interop.NewReader(buf)

	msg, err := scanner.Read()
	Ok(t, err)
	Equals(t, "abcde", string(msg.Body()))
}

func TestMessageReader_ReadMessage2(t *testing.T) {
	buf := bytes.NewBufferString("\nfoo\nbar\n\nbaz")
	scanner := interop.NewReader(buf)

	msg, err := scanner.Read()
	Ok(t, err)
	Equals(t, "foo\nbar\n", string(msg.Body()))

	_, err = scanner.Read()
	Equals(t, io.EOF, err)
}
