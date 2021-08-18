package interop_test

import (
	. "github.com/hx/interop/interop"
	. "github.com/hx/interop/testing"
	"testing"
)

func TestDefaultContentTypes_UnmarshalTo(t *testing.T) {
	source := []byte{'a', 'b', 'c'}
	var target []byte
	Ok(t, StdContentTypes.UnmarshalTo("application/octet-stream", source, &target))
	Equals(t, source, target)
}

func TestDefaultContentTypes_Marshal(t *testing.T) {
	source := []byte{'a', 'b', 'c'}
	result, err := StdContentTypes.Marshal("application/octet-stream", source)
	Ok(t, err)
	Equals(t, source, result)
}

func TestDefaultContentTypes_Unmarshal(t *testing.T) {
	cases := []struct {
		Name     string
		JSON     string
		Expected interface{}
	}{
		{"String", `"hello"`, "hello"},
		{"Number", `5.6`, 5.6},
		{"Negative number", "-10", -10.0},
		{"Array", `[1,2]`, []interface{}{1.0, 2.0}},
		{"Boolean", `true`, true},
		{"Null", `null`, nil},
		{"Object", `{"foo":"bar"}`, map[string]interface{}{"foo": "bar"}},
	}
	for _, c := range cases {
		t.Run(c.Name, func(t *testing.T) {
			result, err := StdContentTypes.Unmarshal("application/json", []byte(c.JSON))
			Ok(t, err)
			Equals(t, c.Expected, result)
		})
	}
}
