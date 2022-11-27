package interop

import (
	"context"
	"regexp"
	"sync"
)

type Responder interface {
	Respond(ctx context.Context, request Message, response *MessageBuilder)
}

type ResponderFunc func(request Message, response *MessageBuilder)

func (f ResponderFunc) Respond(_ context.Context, request Message, response *MessageBuilder) {
	f(request, response)
}

type ResponderContextFunc func(ctx context.Context, request Message, response *MessageBuilder)

func (f ResponderContextFunc) Respond(ctx context.Context, request Message, response *MessageBuilder) {
	f(ctx, request, response)
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

func (d *RpcDispatcher) Respond(ctx context.Context, request Message, response *MessageBuilder) {
	d.mutex.RLock()
	routes := d.routes
	d.mutex.RUnlock()
	for _, route := range routes {
		if route.matcher == nil || route.matcher.Match(request) {
			route.responder.Respond(ctx, request, response)
			return
		}
	}
	// TODO: fallback route?
}
