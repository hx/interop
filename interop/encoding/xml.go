package encoding

import "encoding/xml"

var XML = NewMarshaler(xml.Marshal, nil, xml.Unmarshal)
