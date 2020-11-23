package interop_test

import (
	. "github.com/hx/interop/interop"
	. "github.com/hx/interop/testing"
	"testing"
)

func TestParseHeader_good_source(t *testing.T) {
	source := []byte("foo-bar: baz\n")
	header, err := ParseHeader(source)
	Ok(t, err)
	Equals(t, "Foo-Bar", header.Name())
	Equals(t, "baz", header.Value())
}

func TestParseHeader_bad_source(t *testing.T) {
	source := []byte("foo-bar baz")
	header, err := ParseHeader(source)
	Equals(t, nil, header)
	Equals(t, "bad header: foo-bar baz", err.Error())
}
