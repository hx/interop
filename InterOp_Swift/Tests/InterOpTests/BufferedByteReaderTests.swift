import XCTest
@testable import InterOp

class BufferedByteReaderTests: TestCase {
    var abcde = BufferedByteReader(DataReadWriter())
    
    override func setUp() {
        abcde = BufferedByteReader(DataReadWriter("abcde".data(using: .ascii)!, readChunkSize: 2))
    }
    
    func testReadExactly() async {
        eq("abc", try! await abcde.read(exactly: 3))
        eq("d", try! await abcde.read(exactly: 1))
        await assertAsyncThrowsError(try await abcde.read(exactly: 2)) { error in
            XCTAssertEqual(Errors.alreadyClosed, error as! Errors)
        }
    }
    
    func testReadUntil() async {
        eq("abc", try! await abcde.read(until: "c"))
        eq("de", try! await abcde.read(exactly: 2))
        isNil(try! await abcde.read())
    }
    
    func testReadUntilAtMost() async {
        eq("ab", try! await abcde.read(until: "z", atMost: 2))
        eq("cde", try! await abcde.readAll())
    }
    
    func testReadUntilAtMostShortCircuit() async {
        eq("a", try! await abcde.read(until: "a", atMost: 2))
        eq("bcde", try! await abcde.readAll())
    }
    
    func testReadByte() async {
        eq("a", try! await abcde.readByte())
        eq("b", try! await abcde.readByte())
        eq("c", try! await abcde.readByte())
        eq("de", try! await abcde.readAll())
        isNil(try! await abcde.readByte())
    }

    private func eq(_ expected: String, _ actual: Data?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(expected, String(data: actual!, encoding: .ascii)!, file: file, line: line)
    }

    private func eq(_ expected: UnicodeScalar, _ actual: UInt8?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(UInt8(expected.value), actual!, file: file, line: line)
    }

    private func isNil(_ actual: Any?, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertNil(actual, file: file, line: line)
    }
}
