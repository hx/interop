package interop

import "github.com/hx/interop/interop/encoding"

var StdContentTypes ContentTypes

var ContentTypeJSON = StdContentTypes.Register("application/json", encoding.JSON)
var ContentTypeBinary = StdContentTypes.Register("application/octet-stream", encoding.Null)
