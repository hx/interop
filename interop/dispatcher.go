package interop

import (
	"regexp"
	"sync"
)

type Responder interface {
	Respond(request Message, response *MessageBuilder)
}

type ResponderFunc func(request Message, response *MessageBuilder)

func (f ResponderFunc) Respond(request Message, response *MessageBuilder) {
	f(request, response)
}

type rpcRoute struct {
	matcher   Matcher
	responder Responder
}

type RpcDispatcher struct {
	routes []*rpcRoute
	mutex  sync.RWMutex
}

func (d *RpcDispatcher) Handle(matcher Matcher, responder Responder) {
	d.mutex.Lock()
	d.routes = append(d.routes, &rpcRoute{matcher, responder})
	d.mutex.Unlock()
}

func (d *RpcDispatcher) HandleClassName(name string, responder Responder) {
	d.Handle(MatchClassName(name), responder)
}

func (d *RpcDispatcher) HandleClassRegexp(pattern *regexp.Regexp, responder Responder) {
	d.Handle(MatchClassRegexp(pattern), responder)
}

func (d *RpcDispatcher) Dispatch(request Message, response *MessageBuilder) {
	d.mutex.RLock()
	routes := d.routes
	d.mutex.RUnlock()
	for _, route := range routes {
		if route.matcher == nil || route.matcher.Match(request) {
			route.responder.Respond(request, response)
			return
		}
	}
	// TODO: fallback route?
}
