import Foundation

actor StreamReader : Reader {
    private static let LF = "\n".data(using: .ascii)
    private static let CRLF = "\r\n".data(using: .ascii)

    private let reader: BufferedByteReader

    init(_ reader: ByteReader) {
        self.reader = BufferedByteReader(reader)
    }

    func read() async throws -> Message? {
        let headers = try await readHeaders()
        
        if let contentLengthStr = headers[Header.ContentLength] {
            guard let contentLength = UInt(contentLengthStr) else {
                throw Errors.badHeader(header: "Content-Length: \(contentLengthStr)")
            }
            guard let body = contentLength == 0 ? Data() : try await reader.read(exactly: Int(contentLength)) else {
                throw Errors.alreadyClosed
            }
            var newLine = try await reader.readByte()
            if newLine == 13 { // CR
                newLine = try await reader.readByte()
            }
            if newLine != 10 { // LF
                throw Errors.malformedMessage(details: "Expected a newline after \(contentLength) bytes of content")
            }
            return MessageBuffer(headers, body)
        }
        
        let paragraph = try await readParagraph()
        return paragraph.isEmpty ? nil : MessageBuffer(headers, Data(paragraph.joined()))
    }
    
    private func readHeaders() async throws -> Headers {
        return Headers(
            try await readParagraph().map {
                try Header.parse(String(data: $0, encoding: .utf8) ??
                                 String(data: $0, encoding: .ascii)!)
            }
        )
    }
    
    private func readParagraph() async throws -> [Data] {
        var paragraph = [Data]()
        while let line = try await reader.read(until: "\n") {
            if line == StreamReader.LF || line == StreamReader.CRLF {
                break
            }
            paragraph.append(line)
        }
        return paragraph
    }
}
