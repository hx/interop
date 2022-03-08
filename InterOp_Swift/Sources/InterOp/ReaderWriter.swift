import Foundation

struct ReaderWriter : Conn {
    let reader: Reader
    let writer: Writer
    
    init(_ reader: Reader, _ writer: Writer) {
        self.reader = reader
        self.writer = writer
    }
    
    init(_ reader: ByteReader, _ writer: ByteWriter) {
        self.init(
            StreamReader(reader),
            StreamWriter(writer)
        )
    }
    
    init(_ reader: FileHandle, _ writer: FileHandle) {
        self.init(
            FileReader(reader),
            FileWriter(writer)
        )
    }
    
    func read() async throws -> Message? {
        return try await reader.read()
    }
    
    func write(_ message: Message) async throws {
        try await writer.write(message)
    }
}
