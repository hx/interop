import Foundation

struct FileReader : ByteReader {
    let file: FileHandle
    
    init(_ file: FileHandle) {
        self.file = file
    }
    
    func read() throws -> Data? {
        let data = file.availableData
        return data.isEmpty ? nil : data
    }
}
