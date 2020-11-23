package interop

import (
	"bytes"
	"fmt"
	"io"
	"net/textproto"
)

type Header interface {
	Name() string
	Value() string
}

type header struct {
	name  string
	value string
}

func (h *header) Name() string {
	return h.name
}

func (h *header) Value() string {
	return h.value
}

func NewHeader(name, value string) Header {
	return &header{textproto.CanonicalMIMEHeaderKey(name), value}
}

func matchHeaderName(header Header, name string) bool {
	return header.Name() == textproto.CanonicalMIMEHeaderKey(name)
}

var headerSeparator = []byte{':', ' '}

func writeHeader(header Header, w io.Writer) (n int, err error) {
	n, err = w.Write([]byte(header.Name()))
	if err != nil {
		return
	}

	var n1 int
	n1, err = w.Write(headerSeparator)
	n += n1
	if err != nil {
		return
	}

	n1, err = w.Write([]byte(header.Value()))
	n += n1
	if err != nil {
		return
	}

	n1, err = w.Write([]byte(HeaderDelimiter))
	n += n1
	return
}

func ParseHeader(headerLine []byte) (Header, error) {
	// TODO: multiline, etc
	splitAt := bytes.IndexByte(headerLine, ':')
	if splitAt == -1 {
		return nil, fmt.Errorf("bad header: %s", headerLine)
	}
	return NewHeader(
		string(bytes.TrimSpace(headerLine[0:splitAt])),
		string(bytes.TrimSpace(headerLine[splitAt+1:])),
	), nil
}
