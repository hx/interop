package encoding

import "encoding/json"

var JSON = NewMarshaler(json.Marshal, nil, json.Unmarshal)
