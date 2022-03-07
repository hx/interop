import XCTest
@testable import InterOp

class HeadersTests: XCTestCase {
    let headers = Headers(
        Header("foo", "is foo"),
        Header("bar", "is bar"),
        Header("foo", "is not baz")
    )
    
    func testSubscriptGet() {
        XCTAssertEqual(headers["foo"], "is foo")
        XCTAssertEqual(headers["BAR"], "is bar")
        XCTAssertNil(headers["Baz"])
    }
    
    func testSubscriptSet() {
        var headers = self.headers
        
        headers["foo"] = "new foo"
        XCTAssertEqual(headers["Foo"], "new foo")
        XCTAssertEqual(self.headers["foo"], "is foo")
        
        headers["foo"] = nil
        XCTAssertNil(headers["foo"])
    }
    
    func testGetAll() {
        XCTAssertEqual(headers.getAll("foo"), ["is foo", "is not baz"])
    }
    
    func testAdd() {
        var headers = self.headers
        
        headers.add("bar", "is not foo")
        XCTAssertEqual(headers["bar"], "is bar")
        XCTAssertEqual(headers.getAll("bar"), ["is bar", "is not foo"])
    }
    
    func testDelete() {
        var headers = self.headers
        
        headers.delete("bar")
        XCTAssertNil(headers["bar"])
    }
}
