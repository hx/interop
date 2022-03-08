import XCTest
@testable import InterOp

class StreamReaderTests: XCTestCase {
    private let sourceString = """
Content-Type: application/json

{"foo":"bar"}

Content-Type: text/plain
Content-Length: 5

abcde

"""
    
    private func reader(_ source: String? = nil) -> StreamReader {
        return StreamReader(DataReadWriter((source ?? sourceString).data(using: .ascii)!))
    }
    
    func testRead() async throws {
        let r = reader()
        
        let m1 = try! await r.read()
        
        XCTAssertEqual("{\"foo\":\"bar\"}\n", String(data: m1!.body, encoding: .ascii))
        XCTAssertEqual("application/json", m1!.getHeader(Header.ContentType))
        
        let m2 = try! await r.read()
        
        XCTAssertEqual("abcde", String(data: m2!.body, encoding: .ascii))
        XCTAssertEqual("text/plain", m2!.getHeader(Header.ContentType))
        XCTAssertEqual("5", m2!.getHeader(Header.ContentLength))
        
        let m3 = try! await r.read()
        
        XCTAssertNil(m3)
    }
}
