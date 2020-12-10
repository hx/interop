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
	byteReader *bufio.Reader
	mutex      sync.Mutex
}

func NewReader(r io.Reader) *reader {
	return &reader{byteReader: bufio.NewReader(r)}
}

func (r *reader) Read() (Message, error) {
	r.mutex.Lock()
	defer r.mutex.Unlock()

	headers, err := r.readHeader()
	if err != nil {
		return nil, err
	}

	var (
		message          = &messageBuffer{headers: headers}
		contentLengthStr = headers.Get(MessageContentLengthHeader)
	)

	if contentLengthStr != "" {
		contentLength, _ := strconv.ParseUint(contentLengthStr, 10, 64)
		message.body = make([]byte, contentLength)
		_, err = io.ReadFull(r.byteReader, message.body)
		if err != nil {
			return nil, err
		}
		newline, err := r.byteReader.ReadByte()
		if newline == '\r' {
			newline, err = r.byteReader.ReadByte()
		}
		if err != nil {
			return nil, err
		}
		if newline != '\n' {
			return nil, fmt.Errorf("expected a newline after %d bytes of content", contentLength)
		}
		return message, nil
	}

	paragraph, err := r.readParagraph()
	if err != nil {
		return nil, err
	}
	for _, line := range paragraph {
		message.body = append(message.body, line...)
	}

	return message, nil
}

func (r *reader) readHeader() (Headers, error) {
	paragraph, err := r.readParagraph()
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

func (r *reader) readParagraph() (paragraph [][]byte, err error) {
	var line []byte
	for {
		line, err = r.byteReader.ReadBytes('\n')
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
