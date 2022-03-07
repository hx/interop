import Foundation

struct ContentTypes {
    static let standard = ContentTypes(
        ContentType.json,
        ContentType.binary
    )
    
    private var types: [ContentType]
    
    init(_ types: ContentType...) {
        self.types = types
    }
    
    mutating func register(_ contentTypeName: String, _ marshaler: Marshaler) -> ContentType {
        let contentType = ContentType(contentTypeName, marshaler)
        types.append(contentType)
        return contentType
    }
    
    func findByName(_ contentTypeName: String) -> ContentType? {
        return types.first { $0.name == contentTypeName }
    }
}
