package interop_test

import (
	"bytes"
	. "github.com/hx/interop/interop"
	. "github.com/hx/interop/testing"
	"testing"
)

func TestHeaders_Add(t *testing.T) {
	headers := Headers{}

	Equals(t, &headers, headers.Add("foo-BAR", "Baz"))
	Equals(t, 1, len(headers))
	Equals(t, "Foo-Bar", headers[0].Name())
	Equals(t, "Baz", headers.Get("foo-bar"))

	headers.Add("foo-bar", "Buz")
	Equals(t, 2, len(headers))
	Equals(t, "Foo-Bar", headers[0].Name())
	Equals(t, "Baz", headers.Get("foo-bar"))
	Equals(t, []string{"Baz", "Buz"}, headers.GetAll("foo-bar"))
}

func TestHeaders_Set(t *testing.T) {
	headers := Headers{}

	Equals(t, &headers, headers.Set("foo-bar", "baz"))
	Equals(t, "baz", headers.Get("foo-bar"))

	headers.Set("foo-bar", "buz")
	Equals(t, "buz", headers.Get("foo-bar"))
	Equals(t, 1, len(headers))
}

func TestHeaders_Delete(t *testing.T) {
	headers := Headers{}

	headers.Set("foo-bar", "baz")
	headers.Set("bar-foo", "zab")
	Equals(t, "baz", headers.Get("foo-bar"))
	Equals(t, "zab", headers.Get("bar-foo"))

	Equals(t, &headers, headers.Delete("FOO-BAR"))
	Equals(t, "", headers.Get("foo-bar"))
	Equals(t, "zab", headers.Get("bar-foo"))
	Equals(t, 1, len(headers))
}

func TestHeaders_GetAll(t *testing.T) {
	headers := Headers{}

	headers.Add("foo", "bar")
	headers.Add("fiz", "pop")
	headers.Add("foo", "baz")

	Equals(t, []string{"bar", "baz"}, headers.GetAll("foo"))
}

func TestWriteHeaders(t *testing.T) {
	headers := Headers{}

	headers.Add("foo", "bar")
	headers.Add("fiz-wiz", "pop")
	headers.Add("foo", "baz")

	buf := new(bytes.Buffer)
	n, err := WriteHeaders(headers, buf)
	Ok(t, err)
	Equals(t, int64(31), n)

	expected := `
Foo: bar
Fiz-Wiz: pop
Foo: baz
`[1:]
	Equals(t, expected, buf.String())
}
