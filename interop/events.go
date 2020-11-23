package interop

import (
	"regexp"
	"sync"
)

type EventHandler func(event Message) error

type eventRoute struct {
	matcher MessageMatcher
	handler EventHandler
}

type EventDispatcher struct {
	routes []*eventRoute
	mutex  sync.RWMutex
}

func (d *EventDispatcher) Handle(matcher MessageMatcher, handler EventHandler) {
	d.mutex.Lock()
	d.routes = append(d.routes, &eventRoute{matcher: matcher, handler: handler})
}

func (d *EventDispatcher) HandleClassName(name string, handler EventHandler) {
	d.Handle(MatchClassName(name), handler)
}

func (d *EventDispatcher) HandleClassRegexp(pattern *regexp.Regexp, handler EventHandler) {
	d.Handle(MatchClassRegexp(pattern), handler)
}

func (d *EventDispatcher) Dispatch(event Message) (err error) {
	var route *eventRoute
	for _, route = range d.routes {
		if route.matcher == nil || route.matcher.MatchMessage(event) {
			err = route.handler(event)
			break
		}
	}
	return
}
