import Foundation

class MessageBuffer {
    private let headers: Headers
    let body: Data
    
    init(_ headers: Headers = Headers(), _ body: Data = Data()) {
        self.headers = headers
        self.body = body
    }
}

extension MessageBuffer : Message {
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
