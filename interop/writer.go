package interop

import (
	"bytes"
	"io"
	"sync"
)

type Writer interface {
	Write(message Message) (err error)
}

type writer struct {
	byteWriter io.Writer
	mutex      sync.Mutex
}

func NewWriter(w io.Writer) *writer {
	return &writer{byteWriter: w}
}

func (w *writer) Write(message Message) (err error) {
	w.mutex.Lock()
	_, err = WriteMessage(message, w.byteWriter)
	w.mutex.Unlock()
	return
}

func WriteMessage(message Message, w io.Writer) (n int64, err error) {
	// Write headers, with a newline after each
	n, err = WriteHeaders(message.GetAllHeaders(), w)
	if err != nil {
		return
	}

	// Write another newline
	if err = writeDelimiter(w, &n); err != nil {
		return
	}

	// Write the body
	var n1 int64
	n1, err = bytes.NewBuffer(message.Body()).WriteTo(w)
	n += n1
	if err != nil {
		return
	}

	// Write another newline
	err = writeDelimiter(w, &n)
	return
}

func writeDelimiter(w io.Writer, n *int64) error {
	n1, err := w.Write([]byte(HeaderDelimiter))
	*n += int64(n1)
	return err
}
