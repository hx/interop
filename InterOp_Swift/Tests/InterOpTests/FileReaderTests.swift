import XCTest
@testable import InterOp

class FileReaderTests: XCTestCase {
    private func makeTempFile(_ contents: String, using encoding: String.Encoding = .utf8) -> URL {
        let fileManager = FileManager.default
        let dir = fileManager
            .temporaryDirectory
            .appendingPathComponent("interop_swift_tests", isDirectory: true)
        let file = dir
            .appendingPathComponent(UUID().uuidString)
        
        try! fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        XCTAssertTrue(fileManager.createFile(atPath: file.path, contents: contents.data(using: encoding)))
        addTeardownBlock { try! fileManager.removeItem(at: file) }
        return file
    }
    
    func testRead() throws {
        let url = makeTempFile("foobar")
        let handle = try FileHandle(forReadingFrom: url)
        defer { try? handle.close() }
        let reader = FileReader(handle)
        XCTAssertEqual("foobar", String(data: try! reader.read()!, encoding: .ascii))
    }
}
