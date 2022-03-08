import XCTest
@testable import InterOp

class HeaderTests: XCTestCase {
    func testParse() {
        let header = try! Header.parse("foo_bar:  Baz ")
        XCTAssertEqual(header.name, "Foo-Bar")
        XCTAssertEqual(header.value, "Baz")
    }
    
    func testParseBad() {
        XCTAssertThrowsError(try Header.parse("nope")) { error in
            XCTAssertEqual(error as! Errors, .badHeader(header: "nope"))
        }
    }
    
    func testCanonicalName() {
        let header = Header("foo-baR", "baz")
        XCTAssertEqual(header.name, "Foo-Bar")
    }
}
