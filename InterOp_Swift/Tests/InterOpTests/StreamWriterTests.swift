import XCTest
@testable import InterOp

class StreamWriterTests: XCTestCase {
    func testWrite() async {
        let expectedOutput = """
Content-Type: application/json

{"foo":"bar"}

Content-Type: text/plain
Content-Length: 5

abcde

"""
        let buffer = DataReadWriter()
        let writer = StreamWriter(buffer)
        
        try! await writer.write(
            MessageBuilder()
                .addHeader(Header.ContentType, "application/json")
                .setBody("{\"foo\":\"bar\"}\n".data(using: .ascii)!)
        )
        
        try! await writer.write(
            MessageBuilder()
                .addHeader(Header.ContentType, "text/plain")
                .addHeader(Header.ContentLength, "5")
                .setBody("abcde".data(using: .ascii)!)
        )

        XCTAssertEqual(expectedOutput, String(data: buffer.data, encoding: .ascii))
    }
}
