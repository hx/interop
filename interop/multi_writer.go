package interop

import (
	"strings"
	"sync"
)

type MultiWriter struct {
	mutex   sync.RWMutex
	writers []Writer
}

func (m *MultiWriter) Subscribe(writer Writer) (unsubscribe func()) {
	m.mutex.Lock()
	m.writers = append(m.writers, writer)
	m.mutex.Unlock()

	return func() {
		m.mutex.Lock()
		for i, w := range m.writers {
			if w == writer {
				m.writers = append(m.writers[:i], m.writers[i+1:]...)
			}
		}
		m.mutex.Unlock()
	}
}

func (m *MultiWriter) Write(message Message) error {
	m.mutex.Lock()
	writers := m.writers
	m.mutex.Unlock()

	var errors MultiWriterErrors
	for _, w := range writers {
		if err := w.Write(message); err != nil {
			errors = append(errors, MultiWriterError{w, err})
		}
	}

	if errors != nil {
		return errors
	}

	return nil
}

type MultiWriterError struct {
	Writer Writer
	Error  error
}

type MultiWriterErrors []MultiWriterError

func (m MultiWriterErrors) Error() string {
	str := make([]string, len(m))
	for i, e := range m {
		str[i] = e.Error.Error()
	}
	return strings.Join(str, "; ")
}
