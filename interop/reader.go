package interop

import (
	"bufio"
	"fmt"
	"io"
	"strconv"
	"sync"
)

type Reader interface {
	Read() (message Message, err error)
}

type reader struct {
	r     *bufio.Reader
	mutex sync.Mutex
}

func NewReader(r io.Reader) *reader {
	return &reader{r: bufio.NewReader(r)}
}

func (mr *reader) Read() (Message, error) {
	mr.mutex.Lock()
	defer mr.mutex.Unlock()

	headers, err := mr.readHeader()
	if err != nil {
		return nil, err
	}

	var (
		message          = &messageBuffer{headers: headers}
		contentLengthStr = headers.Get(MessageContentLengthHeader)
	)

	if contentLengthStr != "" {
		contentLength, err := strconv.ParseUint(contentLengthStr, 10, 64)
		if err != nil {
			return nil, fmt.Errorf("invalid %s: %s", MessageContentLengthHeader, contentLengthStr)
		}
		message.body = make([]byte, contentLength)
		_, err = io.ReadFull(mr.r, message.body)
		if err != nil {
			return nil, err
		}
		newline, err := mr.r.ReadByte()
		if newline == '\r' {
			newline, err = mr.r.ReadByte()
		}
		if err != nil {
			return nil, err
		}
		if newline != '\n' {
			return nil, fmt.Errorf("expected a newline after %d bytes of content", contentLength)
		}
		return message, nil
	}

	paragraph, err := mr.readParagraph()
	if err != nil {
		return nil, err
	}
	for _, line := range paragraph {
		message.body = append(message.body, line...)
	}

	return message, nil
}

func (mr *reader) readHeader() (Headers, error) {
	paragraph, err := mr.readParagraph()
	if err != nil {
		return nil, err
	}
	var headers Headers
	var header Header
	for _, line := range paragraph {
		header, err = ParseHeader(line)
		if err != nil {
			return nil, err
		}
		headers = append(headers, header)
	}
	return headers, nil
}

func (mr *reader) readParagraph() (paragraph [][]byte, err error) {
	var line []byte
	for {
		line, err = mr.r.ReadBytes('\n')
		if err != nil {
			return nil, err
		}
		if string(line) == "\n" || string(line) == "\r\n" {
			return
		}
		paragraph = append(paragraph, line)
	}
}

func ReadAllMessages(reader Reader, callback func(message Message) error) (err error) {
	var message Message
	for {
		message, err = reader.Read()
		if err != nil {
			return
		}
		if callback == nil {
			continue
		}
		err = callback(message)
		if err != nil {
			return
		}
	}
}
