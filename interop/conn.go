package interop

import (
	"io"
	"os"
)

type Conn interface {
	Reader
	Writer
}

type conn struct {
	Reader
	Writer
}

func BuildConn(reader io.Reader, writer io.Writer) Conn {
	return CombineReaderWriter(NewReader(reader), NewWriter(writer))
}

func NewConn(conn io.ReadWriter) Conn {
	return BuildConn(conn, conn)
}

func CombineReaderWriter(reader Reader, writer Writer) Conn {
	return &conn{reader, writer}
}

func StdioConn() Conn {
	// TODO: check sync mode etc
	return BuildConn(os.Stdin, os.Stdout)
}
