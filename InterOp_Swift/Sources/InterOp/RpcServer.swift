import Foundation

public actor RpcServer {
    public typealias Setup = (_ responder: RpcResponder) -> Void
    
    private let responder = RpcResponder()
    private let conn: Conn
    private var task: Task<Error?, Never>?
    
    /**
     Returns a new instance of `RpcServer` that reads from standard input, and writes to standard output.
     */
    public static func stdio(_ setup: Setup) -> RpcServer {
        return self.init(ReaderWriter(
            FileReader(FileHandle.standardInput),
            FileWriter(FileHandle.standardOutput)
        ), setup)
    }
    
    public init(_ conn: Conn, _ setup: Setup) {
        self.conn = conn
        setup(responder)
    }
    
    public init(_ fileHandle: FileHandle, _ setup: Setup) {
        self.conn = ReaderWriter(fileHandle, fileHandle)
        setup(responder)
    }
    
    public func start() throws {
        if task != nil {
            throw Errors.alreadyRunning
        }
        task = Task.detached { // TODO: clarify whether "detached" is necessary
            do {
                while let request = try await self.conn.read() {
                    Task {
                        let response = MessageBuilder()
                        self.responder.respond(to: request, with: response)
                        try await self.conn.write(response.setHeader(Header.ID, request.getHeader(Header.ID)))
                    }
                }
                return nil
            } catch {
                return error
            }
        }
    }
    
    public func wait() async -> Error? {
        return await task?.value
    }
    
    public func send(_ event: Message) async throws {
        if event.getHeader(Header.ID) != nil {
            throw Errors.eventHasID
        }
        try await conn.write(event)
    }
}
