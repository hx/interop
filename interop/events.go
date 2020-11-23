package interop

import (
	"regexp"
	"sync"
)

type Handler interface {
	Handle(event Message) error
}

type HandlerFunc func(event Message) error

func (f HandlerFunc) Handle(event Message) error {
	return f(event)
}

type eventRoute struct {
	matcher Matcher
	handler Handler
}

type EventDispatcher struct {
	routes []*eventRoute
	mutex  sync.RWMutex
}

func (d *EventDispatcher) Handle(matcher Matcher, handler Handler) {
	d.mutex.Lock()
	d.routes = append(d.routes, &eventRoute{matcher, handler})
	d.mutex.Unlock()
}

func (d *EventDispatcher) HandleClassName(name string, handler Handler) {
	d.Handle(MatchClassName(name), handler)
}

func (d *EventDispatcher) HandleClassRegexp(pattern *regexp.Regexp, handler Handler) {
	d.Handle(MatchClassRegexp(pattern), handler)
}

func (d *EventDispatcher) Dispatch(event Message) (err error) {
	d.mutex.RLock()
	routes := d.routes
	d.mutex.RUnlock()
	for _, route := range routes {
		if route.matcher == nil || route.matcher.Match(event) {
			if err = route.handler.Handle(event); err != nil {
				break
			}
		}
	}
	return
}
