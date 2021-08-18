package interop

import "github.com/hx/interop/interop/encoding"

type ContentTypes []*ContentType

func (t *ContentTypes) Register(contentTypeName string, marshaller encoding.Marshaler) (contentType *ContentType) {
	contentType = &ContentType{marshaller, contentTypeName}
	*t = append(*t, contentType)
	return
}

func (t ContentTypes) Marshal(contentTypeName string, value interface{}) (b []byte, err error) {
	if ct := t.FindByName(contentTypeName); ct != nil {
		return ct.Marshal(value)
	}
	return nil, ErrUnrecognisedType
}

func (t ContentTypes) Unmarshal(contentTypeName string, b []byte) (result interface{}, err error) {
	if ct := t.FindByName(contentTypeName); ct != nil {
		return ct.Unmarshal(b)
	}
	return nil, ErrUnrecognisedType
}

func (t ContentTypes) UnmarshalTo(contentTypeName string, b []byte, target interface{}) (err error) {
	if ct := t.FindByName(contentTypeName); ct != nil {
		return ct.UnmarshalTo(b, target)
	}
	return ErrUnrecognisedType
}

func (t ContentTypes) Encode(contentTypeName string, value interface{}) (Message, error) {
	if ct := t.FindByName(contentTypeName); ct != nil {
		return ct.Encode(value)
	}
	return nil, ErrUnrecognisedType
}

func (t ContentTypes) EncodeTo(contentTypeName string, builder *MessageBuilder, value interface{}) error {
	if ct := t.FindByName(contentTypeName); ct != nil {
		return ct.EncodeTo(builder, value)
	}
	return ErrUnrecognisedType
}

func (t ContentTypes) Decode(message Message) (result interface{}, err error) {
	return t.Unmarshal(message.GetHeader(MessageContentTypeHeader), message.Body())
}

func (t ContentTypes) DecodeTo(message Message, target interface{}) (err error) {
	return t.UnmarshalTo(message.GetHeader(MessageContentTypeHeader), message.Body(), target)
}

func (t ContentTypes) FindByName(contentTypeName string) *ContentType {
	for _, ct := range t {
		if ct.Name == contentTypeName {
			return ct
		}
	}
	return nil
}
