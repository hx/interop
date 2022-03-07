import Foundation

struct JsonMarshaler : Marshaler {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func marshal<T : Encodable>(_ value: T) throws -> Data {
        return try encoder.encode(value)
    }
    
    func unmarshal<T : Decodable>(_ data: Data, _ toType: T.Type) throws -> T {
        return try decoder.decode(toType, from: data)
    }
}
