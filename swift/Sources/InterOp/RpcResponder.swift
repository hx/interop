import Foundation

struct RpcResponder {
    struct Route {
        let matcher: Matcher?
        let responder: Responder
        
        fileprivate init(_ matcher: Matcher?, _ responder: Responder) {
            self.matcher = matcher
            self.responder = responder
        }
        
        fileprivate init(_ matcher: Matcher?, _ responder: @escaping AnonymousResponder.responderFunction) {
            self.init(matcher, AnonymousResponder(responder))
        }
        
        fileprivate func matches(_ message: Message) -> Bool {
            return matcher?.matches(message) ?? true
        }
    }
    
    var routes = [Route]()
    
    mutating func handle(className: String, with responder: Responder) {
        routes.append(Route(Matcher.className(name: className), responder))
    }
    
    mutating func handle(className: String, responder: @escaping AnonymousResponder.responderFunction) {
        routes.append(Route(Matcher.className(name: className), responder))
    }
    
    mutating func handle(classPattern: NSRegularExpression, with responder: Responder) {
        routes.append(Route(Matcher.classPattern(pattern: classPattern), responder))
    }
    
    mutating func handle(classPattern: NSRegularExpression, responder: @escaping AnonymousResponder.responderFunction) {
        routes.append(Route(Matcher.classPattern(pattern: classPattern), responder))
    }
    
    mutating func handle(_ matcher: Matcher?, with responder: Responder) {
        routes.append(Route(matcher, responder))
    }
    
    mutating func handle(_ matcher: Matcher?, responder: @escaping AnonymousResponder.responderFunction) {
        routes.append(Route(matcher, responder))
    }
}

extension RpcResponder : Responder {
    func respond(to request: Message, with response: MessageBuilder) {
        routes.first { $0.matches(request) }?.responder.respond(to: request, with: response)
    }
}

//protocol RpcRouter {
//    var routes: [RpcResponder.Route] { get }
//    mutating func handle(className: String, with responder: Responder)
//    mutating func handle(className: String, responder: @escaping AnonymousResponder.responderFunction)
//    mutating func handle(classPattern: NSRegularExpression, with responder: Responder)
//    mutating func handle(classPattern: NSRegularExpression, responder: @escaping AnonymousResponder.responderFunction)
//    mutating func handle(_ matcher: Matcher?, with responder: Responder)
//    mutating func handle(_ matcher: Matcher?, responder: @escaping AnonymousResponder.responderFunction)
//}

