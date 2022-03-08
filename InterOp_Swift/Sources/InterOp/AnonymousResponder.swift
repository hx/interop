import Foundation

public struct AnonymousResponder : Responder {
    public typealias responderFunction = (_ request: Message, _ response: MessageBuilder) -> Void
    
    private let fn: responderFunction
    
    init(_ fn: @escaping responderFunction) {
        self.fn = fn
    }
    
    public func respond(to request: Message, with response: MessageBuilder) {
        fn(request, response)
    }
}
