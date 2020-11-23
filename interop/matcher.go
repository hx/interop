package interop

import (
	"regexp"
)

type MessageMatcher interface {
	MatchMessage(message Message) bool
}

type messageClassNameMatcher string

func (m messageClassNameMatcher) MatchMessage(message Message) bool {
	if message == nil {
		return false
	}
	return message.GetHeader(MessageClassHeader) == string(m)
}

func MatchClassName(name string) MessageMatcher {
	return messageClassNameMatcher(name)
}

type messagePatternNameMatcher struct {
	*regexp.Regexp
}

func (m *messagePatternNameMatcher) MatchMessage(message Message) bool {
	if message == nil {
		return false
	}
	return m.MatchString(message.GetHeader(MessageClassHeader))
}

func MatchClassRegexp(pattern *regexp.Regexp) MessageMatcher {
	return &messagePatternNameMatcher{pattern}
}
