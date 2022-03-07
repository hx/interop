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
            try writer.write(header.name.data(using: .ascii)!)
            try writer.write(StreamWriter.HEADER_SEP)
            try writer.write(header.value.data(using: .ascii)!)
            try writer.write(StreamWriter.LF)
        }
        try writer.write(StreamWriter.LF)
        try writer.write(message.body)
        try writer.write(StreamWriter.LF)
    }
}
