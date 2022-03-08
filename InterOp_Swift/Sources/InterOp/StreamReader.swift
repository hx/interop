import Foundation

actor StreamReader : Reader {
    private static let LF = "\n".data(using: .ascii)
    private static let CRLF = "\r\n".data(using: .ascii)

    private let reader: BufferedByteReader

    init(_ reader: ByteReader) {
        self.reader = BufferedByteReader(reader)
    }

    func read() async throws -> Message? {
        let headers = try readHeaders()
        
        if let contentLengthStr = headers[Header.ContentLength] {
            guard let contentLength = UInt(contentLengthStr) else {
                throw Errors.badHeader(header: "Content-Length: \(contentLengthStr)")
            }
            guard let body = contentLength == 0 ? Data() : try reader.read(exactly: Int(contentLength)) else {
                throw Errors.alreadyClosed
            }
            var newLine = try reader.readByte()
            if newLine == 13 { // CR
                newLine = try reader.readByte()
            }
            if newLine != 10 { // LF
                throw Errors.malformedMessage(details: "Expected a newline after \(contentLength) bytes of content")
            }
            return MessageBuffer(headers, body)
        }
        
        let paragraph = try readParagraph()
        return paragraph.isEmpty ? nil : MessageBuffer(headers, Data(paragraph.joined()))
    }
    
    private func readHeaders() throws -> Headers {
        return Headers(
            try readParagraph().map {
                try Header.parse(String(data: $0, encoding: .utf8) ??
                                 String(data: $0, encoding: .ascii)!)
            }
        )
    }
    
    private func readParagraph() throws -> [Data] {
        var paragraph = [Data]()
        while let line = try reader.read(until: "\n") {
            if line == StreamReader.LF || line == StreamReader.CRLF {
                break
            }
            paragraph.append(line)
        }
        return paragraph
    }
}
