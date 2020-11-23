package interop

import (
	"regexp"
)

type Matcher interface {
	Match(message Message) bool
}

type MatcherFunc func(message Message) bool

func (f MatcherFunc) Match(message Message) bool {
	return f(message)
}

type messageClassNameMatcher string

func (m messageClassNameMatcher) Match(message Message) bool {
	if message == nil {
		return false
	}
	return message.GetHeader(MessageClassHeader) == string(m)
}

func MatchClassName(name string) Matcher {
	return messageClassNameMatcher(name)
}

type messagePatternNameMatcher struct {
	*regexp.Regexp
}

func (m *messagePatternNameMatcher) Match(message Message) bool {
	if message == nil {
		return false
	}
	return m.MatchString(message.GetHeader(MessageClassHeader))
}

func MatchClassRegexp(pattern *regexp.Regexp) Matcher {
	return &messagePatternNameMatcher{pattern}
}
