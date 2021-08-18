package encoding_test

import (
	"bytes"
	. "github.com/hx/interop/interop/encoding"
	. "github.com/hx/interop/testing"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHTTPResponseMarshaler_Marshal(t *testing.T) {
	res := &http.Response{
		Status:        "200 OK",
		StatusCode:    200,
		Proto:         "HTTP/1.1",
		ProtoMajor:    1,
		ProtoMinor:    1,
		Header:        http.Header{"Content-Type": []string{"application/json"}},
		Body:          io.NopCloser(bytes.NewBuffer([]byte(`"null"`))),
		ContentLength: 6,
	}
	result, err := HTTPResponseMarshaler.Marshal(res)
	Ok(t, err)
	expected := strings.ReplaceAll(`
HTTP/1.1 200 OK
Content-Length: 6
Content-Type: application/json

"null"`[1:], "\n", "\r\n")
	Equals(t, expected, string(result))
}

func TestHTTPResponseMarshaler_Unmarshal(t *testing.T) {
	input := `
HTTP/1.1 200 OK
Content-Length: 6
Content-Type: application/json

"null"`[1:]
	result, err := HTTPResponseMarshaler.Unmarshal([]byte(input))
	Ok(t, err)
	res, _ := result.(*http.Response)
	Equals(t, 200, res.StatusCode)
	Equals(t, "200 OK", res.Status)
	Equals(t, "HTTP/1.1", res.Proto)
	Equals(t, "application/json", res.Header.Get("Content-Type"))
	Equals(t, int64(6), res.ContentLength)
	body, _ := io.ReadAll(res.Body)
	Equals(t, `"null"`, string(body))
}

func TestHTTPResponseMarshaler_UnmarshalTo(t *testing.T) {
	req, _ := http.NewRequest("GET", "http://example.com/foo", nil)
	res := &http.Response{Request: req}
	input := `
HTTP/1.1 200 OK
Content-Length: 6
Content-Type: application/json

"null"`[1:]
	Ok(t, HTTPResponseMarshaler.UnmarshalTo([]byte(input), res))
	Equals(t, req, res.Request)
	Equals(t, 200, res.StatusCode)
	Equals(t, "200 OK", res.Status)
	Equals(t, "HTTP/1.1", res.Proto)
	Equals(t, "application/json", res.Header.Get("Content-Type"))
	Equals(t, int64(6), res.ContentLength)
	body, _ := io.ReadAll(res.Body)
	Equals(t, `"null"`, string(body))
}

func TestHTTPResponseMarshaler_UnmarshalToWriter(t *testing.T) {
	writer := httptest.NewRecorder()
	input := `
HTTP/1.1 200 OK
Content-Length: 6
Content-Type: application/json

"null"`[1:]
	Ok(t, HTTPResponseMarshaler.UnmarshalTo([]byte(input), writer))
	res := writer.Result()
	Equals(t, 200, res.StatusCode)
	Equals(t, "200 OK", res.Status)
	Equals(t, "HTTP/1.1", res.Proto)
	Equals(t, "application/json", res.Header.Get("Content-Type"))
	Equals(t, int64(6), res.ContentLength)
	body, _ := io.ReadAll(res.Body)
	Equals(t, `"null"`, string(body))
}
