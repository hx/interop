import Foundation

public class MessageBuilder {
    var headers = Headers()
    private(set) public var body = Data()
    
    public init() {}
    
    public func setHeader(_ name: String, _ value: String?) -> MessageBuilder {
        headers[name] = value
        return self
    }
    
    public func addHeader(_ name: String, _ value: String) -> MessageBuilder {
        return addHeader(Header(name, value))
    }
    
    public func addHeader(_ header: Header) -> MessageBuilder {
        headers.add(header)
        return self
    }

    public func addError(_ message: String) -> MessageBuilder {
        return addHeader(Header.Error, message)
    }
    
    public func setBody(_ data: Data) -> MessageBuilder {
        body = data
        return self
    }
    
    public func setContent<T : Encodable>(_ contentType: ContentType, _ content: T) throws -> MessageBuilder {
        try contentType.encodeTo(self, content)
        return self
    }
    
    func setContentType(_ contentTypeName: String) -> MessageBuilder {
        return setHeader(Header.ContentType, contentTypeName)
    }
    
    func setContentLength() -> MessageBuilder {
        return setHeader(Header.ContentLength, String(body.count))
    }
}

extension MessageBuilder : Message {
    public func getHeader(_ headerName: String) -> String? {
        return headers[headerName]
    }
    
    public func getHeaders(_ headerName: String) -> [String] {
        return headers.getAll(headerName)
    }
    
    public func getAllHeaders() -> Headers {
        return headers
    }
}
