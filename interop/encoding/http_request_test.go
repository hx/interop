package encoding_test

import (
	"bytes"
	. "github.com/hx/interop/interop/encoding"
	. "github.com/hx/interop/testing"
	"io"
	"net/http"
	"strings"
	"testing"
)

func TestHTTPRequestMarshaler_Marshal(t *testing.T) {
	req, _ := http.NewRequest("POST", "http://foo.bar/baz?a=1", bytes.NewBuffer([]byte("Hello!")))
	result, err := HTTPRequestMarshaler.Marshal(req)
	Ok(t, err)
	expected := strings.ReplaceAll(`
POST /baz?a=1 HTTP/1.1
Host: foo.bar
User-Agent: Go-http-client/1.1
Content-Length: 6
Accept-Encoding: gzip

Hello!`[1:], "\n", "\r\n")
	Equals(t, expected, string(result))
}

func TestHTTPRequestMarshaler_Marshal_Inbound(t *testing.T) {
	req, _ := http.NewRequest("POST", "/baz?a=1", bytes.NewBuffer([]byte("Hello!")))
	result, err := HTTPRequestMarshaler.Marshal(req)
	Ok(t, err)
	expected := strings.ReplaceAll(`
POST /baz?a=1 HTTP/1.1

Hello!`[1:], "\n", "\r\n")
	Equals(t, expected, string(result))
}

func TestHTTPRequestMarshaler_Unmarshal(t *testing.T) {
	original := `
PATCH /foo/bar/baz?x=y HTTP/1.1
Host: example.com
Content-Length: 4

yoho`[1:]
	result, err := HTTPRequestMarshaler.Unmarshal([]byte(original))
	Ok(t, err)
	req := result.(*http.Request)
	Equals(t, "PATCH", req.Method)
	Equals(t, "example.com", req.Host)
	Equals(t, int64(4), req.ContentLength)
	body, _ := io.ReadAll(req.Body)
	Equals(t, "yoho", string(body))
}
