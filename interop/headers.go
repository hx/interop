package interop

import (
	"io"
)

type Headers []Header

func (h *Headers) Add(name, value string) *Headers {
	n := append(*h, NewHeader(name, value))
	*h = n
	return h
}

func (h *Headers) Set(name, value string) *Headers {
	h.Delete(name)
	return h.Add(name, value)
}

func (h *Headers) Delete(name string) *Headers {
	if count := len(h.GetAll(name)); count > 0 {
		o := *h
		n := make(Headers, 0, len(o)-count)
		for _, header := range o {
			if !matchHeaderName(header, name) {
				n = append(n, header)
			}
		}
		*h = n
	}
	return h
}

func (h Headers) Get(name string) string {
	for _, header := range h {
		if matchHeaderName(header, name) {
			return header.Value()
		}
	}
	return ""
}

func (h Headers) GetAll(name string) (values []string) {
	for _, header := range h {
		if matchHeaderName(header, name) {
			values = append(values, header.Value())
		}
	}
	return
}

func WriteHeaders(headers []Header, w io.Writer) (n int64, err error) {
	var n1 int
	for _, header := range headers {
		if n1, err = writeHeader(header, w); err == nil {
			n += int64(n1)
		} else {
			return
		}
	}
	return
}
