package encoding

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"net/http"
	"net/http/httputil"
)

func marshalHTTPResponse(value interface{}) (b []byte, err error) {
	var res *http.Response

	if value, ok := value.(http.Response); ok {
		return marshalHTTPResponse(&value)
	}

	res, _ = value.(*http.Response)
	if res == nil {
		return nil, fmt.Errorf("expected value %T to be an http.Response or *http.Response", value)
	}

	return httputil.DumpResponse(res, true)
}

func unmarshalHTTPResponse(b []byte) (interface{}, error) {
	res, err := http.ReadResponse(bufio.NewReader(bytes.NewBuffer(b)), nil)
	return res, err
}

func unmarshalHTTPResponseTo(b []byte, target interface{}) error {
	var req *http.Request

	if target, ok := target.(*http.Response); ok {
		if target != nil {
			req = target.Request
		}
		res, err := http.ReadResponse(bufio.NewReader(bytes.NewBuffer(b)), req)
		if err != nil {
			return err
		}
		*target = *res
		return nil
	}

	if target, ok := target.(http.ResponseWriter); ok {
		res, err := http.ReadResponse(bufio.NewReader(bytes.NewBuffer(b)), req)
		if err != nil {
			return err
		}

		targetHeader := target.Header()
		for name, values := range res.Header {
			targetHeader[name] = values
		}
		target.WriteHeader(res.StatusCode)

		if res.Body != nil {
			if _, err := io.Copy(target, res.Body); err != nil {
				return err
			}
			return res.Body.Close()
		}

		return nil
	}

	return fmt.Errorf("expected target %T to be an *http.Response or http.ResponseWriter", target)
}

var HTTPResponseMarshaler = NewMarshaler(
	marshalHTTPResponse,
	unmarshalHTTPResponse,
	unmarshalHTTPResponseTo,
)
