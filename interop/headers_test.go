package interop_test

import (
	. "github.com/hx/interop/interop"
	. "github.com/hx/interop/testing"
	"testing"
)

func TestHeaders_Add(t *testing.T) {
	var headers Headers
	headers.Add("foo-BAR", "Baz")
	Equals(t, 1, len(headers))
	Equals(t, "Foo-Bar", headers[0].Name)
	Equals(t, "Baz", headers.Get("foo-bar"))
}
