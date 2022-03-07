import XCTest
@testable import InterOp

class DataReadWriterTests: XCTestCase {
    func testReadSmallChunks() {
        let rw = DataReadWriter("abcde".data(using: .ascii)!, readChunkSize: 2)
        XCTAssertEqual("ab".data(using: .ascii), try! rw.read()!)
        XCTAssertEqual("cd".data(using: .ascii), try! rw.read()!)
        XCTAssertEqual("e".data(using: .ascii), try! rw.read()!)
        XCTAssertNil(try! rw.read())
    }
    
    func testReadLargeChunks() {
        let rw = DataReadWriter("abcde".data(using: .ascii)!, readChunkSize: 1024)
        XCTAssertEqual("abcde".data(using: .ascii), try! rw.read()!)
        XCTAssertNil(try! rw.read())
    }
    
    func testReadUnlimited() {
        let rw = DataReadWriter("abcde".data(using: .ascii)!, readChunkSize: nil)
        XCTAssertEqual("abcde".data(using: .ascii), try! rw.read()!)
        XCTAssertNil(try! rw.read())
    }
    
    func testWrite() {
        let rw = DataReadWriter()
        try! rw.write("ab".data(using: .ascii)!)
        try! rw.write("cde".data(using: .ascii)!)
        XCTAssertEqual("abcde".data(using: .ascii), try! rw.read()!)
    }
}
