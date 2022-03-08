import Foundation

public class ContentType {
    static let json = ContentType("application/json", JsonMarshaler())
    static let binary = ContentType("application/octet-stream", BinaryMarshaler())
    
    let name: String
    let marshaler: Marshaler
    
    init(_ name: String, _ marshaler: Marshaler) {
        self.name = name
        self.marshaler = marshaler
    }
    
    func encodeTo<T : Encodable>(_ builder: MessageBuilder, _ value: T) throws {
        _ = builder
            .setBody(try marshaler.marshal(value))
            .setContentType(name)
    }
}
