package interop

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"strconv"
)

// Scanner reads a byte stream and emits messages.
type Scanner struct {
	r *bufio.Reader
}

func NewScanner(r io.Reader) *Scanner {
	return &Scanner{r: bufio.NewReader(r)}
}

func (s *Scanner) Read() (*Message, error) {
	headers, err := s.readHeader()
	if err != nil {
		return nil, err
	}

	var (
		message          = &Message{Headers: headers}
		contentLengthStr = headers.Get("Content-Length")
	)

	if contentLengthStr != "" {
		contentLength, err := strconv.ParseUint(contentLengthStr, 10, 64)
		if err != nil {
			return nil, fmt.Errorf("invalid Content-Length: %s", contentLengthStr)
		}
		message.Body = make([]byte, contentLength)
		n, err := io.ReadFull(s.r, message.Body)
		if err != nil {
			return nil, err
		}
		if n != int(contentLength) {
			return nil, fmt.Errorf("expected %d bytes, but only received %d bytes", contentLength, n)
		}
		newline, err := s.r.ReadByte()
		if newline == '\r' {
			newline, err = s.r.ReadByte()
		}
		if err != nil {
			return nil, err
		}
		if newline != '\n' {
			return nil, fmt.Errorf("expected a newline after %d bytes of content", contentLength)
		}
		return message, nil
	}

	chunk, err := s.readChunk()
	if err != nil {
		return nil, err
	}
	for _, line := range chunk {
		message.Body = append(message.Body, line...)
	}

	return message, nil
}

func (s *Scanner) readHeader() (Headers, error) {
	chunk, err := s.readChunk()
	if err != nil {
		return nil, err
	}
	var headers Headers
	for _, line := range chunk {
		splitAt := bytes.IndexByte(line, ':')
		if splitAt == -1 {
			return nil, fmt.Errorf("bad header: %s", string(line))
		}
		headers.Add(
			string(bytes.TrimSpace(line[0:splitAt])),
			string(bytes.TrimSpace(line[splitAt+1:])),
		)
	}
	return headers, nil
}

func (s *Scanner) readChunk() (chunk [][]byte, err error) {
	var line []byte
	for {
		line, err = s.r.ReadBytes('\n')
		if err != nil {
			return nil, err
		}
		if string(line) == "\n" || string(line) == "\r\n" {
			return
		}
		chunk = append(chunk, line)
	}
}
