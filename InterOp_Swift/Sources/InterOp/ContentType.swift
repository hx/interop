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
    
    func encode<T : Encodable>(_ value: T) throws -> Message {
        let builder = MessageBuilder()
        try encode(value, to: builder)
        return builder
    }
    
    func encode<T : Encodable>(_ value: T, to builder: MessageBuilder) throws {
        _ = builder
            .setBody(try marshaler.marshal(value))
            .setContentType(name)
    }
    
    func decode<T : Decodable>(_ message: Message) throws -> T {
        return try marshaler.unmarshal(message.body, T.self)
    }
}
