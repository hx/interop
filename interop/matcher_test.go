package interop_test

import (
	. "github.com/hx/interop/interop"
	. "github.com/hx/interop/testing"
	"regexp"
	"testing"
)

func TestMatchClassName(t *testing.T) {
	matcher := MatchClassName("foo")
	Equals(t, true, matcher.Match(NewRpcMessage("foo")))
	Equals(t, false, matcher.Match(NewRpcMessage("bar")))
	Equals(t, false, matcher.Match(nil))
}

func TestMatchClassRegexp(t *testing.T) {
	matcher := MatchClassRegexp(regexp.MustCompile(`oo$`))
	Equals(t, true, matcher.Match(NewRpcMessage("foo")))
	Equals(t, false, matcher.Match(NewRpcMessage("bar")))
	Equals(t, false, matcher.Match(nil))
}
