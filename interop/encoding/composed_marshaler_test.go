package encoding_test

import (
	"errors"
	"fmt"
	. "github.com/hx/interop/interop/encoding"
	. "github.com/hx/interop/testing"
	"testing"
)

func TestComposedMarshaler_UnmarshalTo(t *testing.T) {
	type Coord struct {
		X uint8
		Y uint8
	}
	bad := errors.New("nope")
	marshal := func(value interface{}) (b []byte, err error) {
		if value, ok := value.(Coord); ok {
			return []byte{value.X, value.Y}, nil
		}
		return nil, fmt.Errorf("expected value of type %T to be a Coord", value)
	}
	unmarshal := func(b []byte) (result interface{}, err error) {
		if len(b) != 2 {
			return nil, bad
		}
		return Coord{b[0], b[1]}, nil
	}
	t.Run("UnmarshalTo using Unmarshal", func(t *testing.T) {
		marshaler := NewMarshaler(marshal, unmarshal, nil)

		t.Run("with the return type", func(t *testing.T) {
			var target = Coord{}
			Ok(t, marshaler.UnmarshalTo([]byte{5, 6}, &target))
			Equals(t, Coord{5, 6}, target)
		})

		t.Run("with a pointer to the return type", func(t *testing.T) {
			var target = &Coord{}
			Ok(t, marshaler.UnmarshalTo([]byte{5, 6}, &target))
			Equals(t, Coord{5, 6}, *target)
		})

		t.Run("with a convertible type", func(t *testing.T) {
			type C Coord
			var target = C{}
			Ok(t, marshaler.UnmarshalTo([]byte{5, 6}, &target))
			Equals(t, C{5, 6}, target)
		})

		t.Run("with a pointer to a convertible type", func(t *testing.T) {
			type C Coord
			var target = &C{}
			Ok(t, marshaler.UnmarshalTo([]byte{5, 6}, &target))
			Equals(t, C{5, 6}, *target)
		})

		t.Run("with a bad type", func(t *testing.T) {
			var target []byte
			err := marshaler.UnmarshalTo([]byte{5, 6}, &target)
			Equals(t, "cannot assign encoding_test.Coord to []uint8", err.Error())
		})
	})
}
