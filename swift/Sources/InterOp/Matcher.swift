import Foundation

public enum Matcher {
    public typealias matchFunc = (_: Message) -> Bool
    
    case className(name: String),
         classPattern(pattern: NSRegularExpression),
         custom(fn: matchFunc)
    
    init(_ fn: @escaping matchFunc) {
        self = .custom(fn: fn)
    }
    
    func matches(_ message: Message) -> Bool {
        switch self {
        case .className(let name):
            return message.getHeader(Header.Class) ?? "" == name
        case .classPattern(let pattern):
            if let klass = message.getHeader(Header.Class) {
                return pattern.firstMatch(in: klass, options: [], range: NSRange(location: 0, length: klass.count)) != nil
            }
            return false
        case .custom(let fn):
            return fn(message)
        }
    }
}
