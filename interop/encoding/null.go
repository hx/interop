package encoding

import (
	"errors"
)

var Null = NewMarshaler(
	func(value interface{}) (b []byte, err error) {
		if value, ok := value.([]byte); ok {
			b = value
		} else {
			err = errors.New("expected a byte slice")
		}
		return
	},
	func(b []byte) (interface{}, error) { return b, nil },
	func(b []byte, target interface{}) (err error) {
		if target, ok := target.(*[]byte); ok {
			*target = b
		} else {
			err = errors.New("expect a byte slice pointer")
		}
		return
	},
)
