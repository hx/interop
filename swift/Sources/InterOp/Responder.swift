protocol Responder {
    func respond(to request: Message, with response: MessageBuilder)
}
