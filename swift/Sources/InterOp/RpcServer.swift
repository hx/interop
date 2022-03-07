import Foundation

actor RpcServer {
    private(set) var responder = RpcResponder()
    private let conn: Conn
    private var task: Task<Error?, Never>?
    
    init(_ conn: Conn) {
        self.conn = conn
    }
    
    func start() throws {
        if task != nil {
            throw Errors.alreadyRunning
        }
        task = Task.detached { // TODO: clarify whether "detached" is necessary
            do {
                while let request = try await self.conn.read() {
                    Task {
                        let response = MessageBuilder()
                        await self.responder.respond(to: request, with: response)
                        try await self.conn.write(response.setHeader(Header.ID, request.getHeader(Header.ID)))
                    }
                }
                return nil
            } catch {
                return error
            }
        }
    }
    
    func wait() async -> Error? {
        return await task?.value
    }
    
    func send(_ event: Message) async throws {
        if event.getHeader(Header.ID) != nil {
            throw Errors.eventHasID
        }
        try await conn.write(event)
    }
}
