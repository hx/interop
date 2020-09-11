package interop

import (
	"bytes"
	"strings"
)

type Headers []*Header

type Header struct {
	Name  string
	Value string
}

const HeaderDelimiter = "\n"

func (h *Headers) Add(name, value string) *Headers {
	n := append(*h, &Header{normalizeHeaderName(name), value})
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
			if !header.matchName(name) {
				n = append(n, header)
			}
		}
		*h = n
	}
	return h
}

func (h Headers) Get(name string) string {
	for _, header := range h {
		if header.matchName(name) {
			return header.Value
		}
	}
	return ""
}

func (h Headers) GetAll(name string) (values []string) {
	for _, header := range h {
		if header.matchName(name) {
			values = append(values, header.Value)
		}
	}
	return
}

func (h Headers) String() (str string) {
	for _, header := range h {
		str += header.String()
	}
	return
}

func (h *Header) String() string {
	return h.Name + ": " + h.Value + HeaderDelimiter
}

func (h *Header) matchName(name string) bool {
	return h.Name == normalizeHeaderName(name)
}

func normalizeHeaderName(name string) string {
	var (
		sep   = []byte{'-'}
		parts = bytes.Split([]byte(strings.ToLower(name)), sep)
	)
	for i, part := range parts {
		if len(part) > 0 {
			parts[i][0] = bytes.ToUpper(part[:1])[0]
		}
	}
	return string(bytes.Join(parts, sep))
}
