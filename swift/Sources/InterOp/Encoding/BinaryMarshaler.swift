import Foundation

struct BinaryMarshaler : Marshaler {
    func marshal<T : Encodable>(_ value: T) throws -> Data {
        guard let value = value as? Data else {
            throw Errors.unrecognisedType
        }
        return value
    }
    
    func unmarshal<T : Decodable>(_ data: Data, _ toType: T.Type) throws -> T {
        if toType == Data.self {
            return data as! T
        }
        throw Errors.unrecognisedType
    }
}
