import Foundation

protocol Marshaler {
    func marshal<T : Encodable>(_ value: T) throws -> Data
    func unmarshal<T : Decodable>(_ data: Data, _ type: T.Type) throws -> T
}
