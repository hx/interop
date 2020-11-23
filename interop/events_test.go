package interop_test

import (
	"errors"
	. "github.com/hx/interop/interop"
	. "github.com/hx/interop/testing"
	"testing"
)

func TestEventDispatcher_Dispatch_uses_matching_handler(t *testing.T) {
	var results []string
	var dispatcher = new(EventDispatcher)

	dispatcher.HandleClassName("foo", HandlerFunc(func(event Message) error {
		results = append(results, event.GetHeader(MessageClassHeader))
		return nil
	}))

	Ok(t, dispatcher.Dispatch(NewRpcMessage("foo")))
	Ok(t, dispatcher.Dispatch(NewRpcMessage("bar")))

	Equals(t, []string{"foo"}, results)
}

func TestEventDispatcher_Dispatch_returns_errors(t *testing.T) {
	var dispatcher = new(EventDispatcher)
	var oops = errors.New("oops")

	dispatcher.HandleClassName("foo", HandlerFunc(func(event Message) error {
		return oops
	}))

	Ok(t, dispatcher.Dispatch(NewRpcMessage("bar")))
	Equals(t, oops, dispatcher.Dispatch(NewRpcMessage("foo")))
}
