import XCTest
@testable import InterOp

class BufferedByteReaderTests: XCTestCase {
    var abcde = BufferedByteReader(DataReadWriter())
    
    override func setUp() {
        abcde = BufferedByteReader(DataReadWriter("abcde".data(using: .ascii)!, readChunkSize: 2))
    }
    
    func testReadExactly() {
        XCTAssertEqual("abc", str(try! abcde.read(exactly: 3)!))
        XCTAssertEqual("d", str(try! abcde.read(exactly: 1)!))
        XCTAssertThrowsError(try abcde.read(exactly: 2)) { error in
            XCTAssertEqual(Errors.alreadyClosed, error as! Errors)
        }
    }
    
    func testReadUntil() {
        XCTAssertEqual("abc", str(try! abcde.read(until: "c")))
        XCTAssertEqual("de", str(try! abcde.read(exactly: 2)))
        XCTAssertNil(try! abcde.read())
    }
    
    func testReadUntilAtMost() {
        XCTAssertEqual("ab", str(try! abcde.read(until: "z", atMost: 2)))
        XCTAssertEqual("cde", str(try! abcde.readAll()))
    }
    
    func testReadUntilAtMostShortCircuit() {
        XCTAssertEqual("a", str(try! abcde.read(until: "a", atMost: 2)))
        XCTAssertEqual("bcde", str(try! abcde.readAll()))
    }
    
    func testReadByte() {
        XCTAssertEqual(val("a"), try! abcde.readByte())
        XCTAssertEqual(val("b"), try! abcde.readByte())
        XCTAssertEqual(val("c"), try! abcde.readByte())
        XCTAssertEqual("de", str(try! abcde.readAll()))
        XCTAssertNil(try! abcde.readByte())
    }
    
    private func str(_ data: Data?) -> String {
        return String(data: data!, encoding: .ascii)!
    }
    
    private func val(_ character: UnicodeScalar) -> UInt8 {
        return UInt8(character.value)
    }
}
