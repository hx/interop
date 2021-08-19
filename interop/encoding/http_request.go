package encoding

import (
	"bufio"
	"bytes"
	"fmt"
	"net/http"
	"net/http/httputil"
)

func marshalHTTPRequest(value interface{}) (b []byte, err error) {
	var req *http.Request

	if value, ok := value.(http.Request); ok {
		return marshalHTTPRequest(&value)
	}

	req, _ = value.(*http.Request)
	if req == nil {
		return nil, fmt.Errorf("expected value %T to be an http.Request or *http.Request", value)
	}

	if req.URL.IsAbs() {
		return httputil.DumpRequestOut(req, true)
	}

	return httputil.DumpRequest(req, true)
}

func unmarshalHTTPRequest(b []byte) (interface{}, error) {
	req, err := http.ReadRequest(bufio.NewReader(bytes.NewBuffer(b)))
	return req, err
}

var HTTPRequestMarshaler = NewMarshaler(marshalHTTPRequest, unmarshalHTTPRequest, nil)
