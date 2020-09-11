package testing

import (
	"fmt"
	"reflect"
	"testing"
)

func Assert(t *testing.T, cond bool, msg string) {
	t.Helper()
	if !cond {
		t.Error(msg)
		t.Fail()
	}
}

func Equals(t *testing.T, exp interface{}, act interface{}) {
	t.Helper()
	Assert(t, reflect.DeepEqual(exp, act), fmt.Sprintf("Expected %+v\nGot %+v\n", exp, act))
}

func Ok(t *testing.T, err error) {
	t.Helper()
	Assert(t, err == nil, fmt.Sprintf("Expected no error, but got %+v", err))
}
