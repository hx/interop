package interop

import (
	"regexp"
	"sync"
)

type Procedure func(request Message, response *MessageBuilder)

type rpcRoute struct {
	matcher MessageMatcher
	proc    Procedure
}

type RpcDispatcher struct {
	routes []*rpcRoute
	mutex  sync.RWMutex
}

func (d *RpcDispatcher) Handle(matcher MessageMatcher, proc Procedure) {
	d.mutex.Lock()
	d.routes = append(d.routes, &rpcRoute{matcher, proc})
	d.mutex.Unlock()
}

func (d *RpcDispatcher) HandleClassName(name string, proc Procedure) {
	d.Handle(MatchClassName(name), proc)
}

func (d *RpcDispatcher) HandleClassRegexp(pattern *regexp.Regexp, proc Procedure) {
	d.Handle(MatchClassRegexp(pattern), proc)
}

func (d *RpcDispatcher) Dispatch(request Message, response *MessageBuilder) {
	if match := d.findRoute(request); match != nil {
		match.proc(request, response)
	}
}

func (d *RpcDispatcher) findRoute(request Message) (match *rpcRoute) {
	d.mutex.RLock()
	for _, route := range d.routes {
		if route.matcher == nil || route.matcher.MatchMessage(request) {
			match = route
			break
		}
	}
	// todo: fallback route
	d.mutex.RUnlock()
	return
}
