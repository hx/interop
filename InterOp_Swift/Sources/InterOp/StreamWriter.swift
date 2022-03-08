import Foundation

actor StreamWriter : Writer {
    private static var LF = "\n".data(using: .ascii)!
    private static var HEADER_SEP = ": ".data(using: .ascii)!
    
    private var writer: ByteWriter
    
    init(_ writer: ByteWriter) {
        self.writer = writer
    }
    
    func write(_ message: Message) async throws {
        for header in message.getAllHeaders() {
            try await writer.write(header.name.data(using: .ascii)!)
            try await writer.write(StreamWriter.HEADER_SEP)
            try await writer.write(header.value.data(using: .ascii)!)
            try await writer.write(StreamWriter.LF)
        }
        try await writer.write(StreamWriter.LF)
        try await writer.write(message.body)
        try await writer.write(StreamWriter.LF)
    }
}
