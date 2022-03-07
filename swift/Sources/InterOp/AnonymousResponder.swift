import Foundation

struct AnonymousResponder : Responder {
    typealias responderFunction = (_ request: Message, _ response: MessageBuilder) -> Void
    
    private let fn: responderFunction
    
    init(_ fn: @escaping responderFunction) {
        self.fn = fn
    }
    
    func respond(to request: Message, with response: MessageBuilder) {
        fn(request, response)
    }
}
