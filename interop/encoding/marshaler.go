package encoding

import (
	"errors"
	"fmt"
	"reflect"
)

type MarshalFunc func(value interface{}) (b []byte, err error)
type UnmarshalToFunc func(b []byte, target interface{}) (err error)
type UnmarshalFunc func(b []byte) (result interface{}, err error)

type Marshaler interface {
	Marshal(value interface{}) (b []byte, err error)
	Unmarshal(b []byte) (result interface{}, err error)
	UnmarshalTo(b []byte, target interface{}) (err error)
}

type composedMarshaler struct {
	marshal     MarshalFunc
	unmarshal   UnmarshalFunc
	unmarshalTo UnmarshalToFunc
}

func NewMarshaler(marshalFunc MarshalFunc, unmarshalFunc UnmarshalFunc, unmarshalToFunc UnmarshalToFunc) Marshaler {
	if unmarshalFunc == nil && unmarshalToFunc == nil {
		panic("unmarshalFunc and unmarshalToFunc cannot both be nil")
	}
	if marshalFunc == nil {
		panic("marshalFunc cannot be nil")
	}
	return &composedMarshaler{marshalFunc, unmarshalFunc, unmarshalToFunc}
}

func (c composedMarshaler) Marshal(v interface{}) ([]byte, error) { return c.marshal(v) }

func (c composedMarshaler) Unmarshal(b []byte) (interface{}, error) {
	if c.unmarshal != nil {
		return c.unmarshal(b)
	}
	if c.unmarshalTo != nil {
		result := new(interface{})
		return *result, c.unmarshalTo(b, result)
	}
	panic("the Marshaler has neither an unmarshal or an unmarshalTo function")
}

func (c composedMarshaler) UnmarshalTo(b []byte, target interface{}) error {
	if c.unmarshalTo != nil {
		return c.unmarshalTo(b, target)
	}
	if c.unmarshal != nil {
		targetValue := reflect.ValueOf(target)
		if targetValue.Kind() != reflect.Ptr {
			return errors.New("expected a pointer")
		}
		targetValue = targetValue.Elem()
		result, err := c.unmarshal(b)
		if err != nil {
			return err
		}
		resultValue := reflect.ValueOf(result)
		return tryAssign(resultValue, targetValue)
	}
	panic("the Marshaler has neither an unmarshal or an unmarshalTo function")
}

func tryAssign(result, target reflect.Value) error {
	var (
		resultType = result.Type()
		targetType = target.Type()
	)
	if resultType == targetType {
		target.Set(result)
		return nil
	}
	if resultType.ConvertibleTo(targetType) {
		target.Set(result.Convert(targetType))
		return nil
	}
	if target.Kind() == reflect.Ptr {
		return tryAssign(result, target.Elem())
	}
	return fmt.Errorf("cannot assign %s to %s", resultType, targetType)
}
