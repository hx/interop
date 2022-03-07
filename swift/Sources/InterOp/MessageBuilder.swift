import Foundation

class MessageBuilder {
    var headers = Headers()
    var body = Data()
    
    func setHeader(_ name: String, _ value: String?) -> MessageBuilder {
        headers[name] = value
        return self
    }
    
    func addHeader(_ name: String, _ value: String) -> MessageBuilder {
        return addHeader(Header(name, value))
    }
    
    func addHeader(_ header: Header) -> MessageBuilder {
        headers.add(header)
        return self
    }

    func addError(_ message: String) -> MessageBuilder {
        return addHeader(Header.Error, message)
    }
    
    func setBody(_ data: Data) -> MessageBuilder {
        body = data
        return self
    }
    
    func setContent<T : Encodable>(_ contentType: ContentType, _ content: T) throws -> MessageBuilder {
        try contentType.encodeTo(self, content)
        return self
    }
    
    internal func setContentType(_ contentTypeName: String) -> MessageBuilder {
        return setHeader(Header.ContentType, contentTypeName)
    }
    
    internal func setContentLength() -> MessageBuilder {
        return setHeader(Header.ContentLength, String(body.count))
    }
}

extension MessageBuilder : Message {
    func getHeader(_ headerName: String) -> String? {
        return headers[headerName]
    }
    
    func getHeaders(_ headerName: String) -> [String] {
        return headers.getAll(headerName)
    }
    
    func getAllHeaders() -> Headers {
        return headers
    }
}
