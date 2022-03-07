import Foundation

struct FileReader : ByteReader {
    let file: FileHandle
    
    func read() throws -> Data? {
        let data = file.availableData
        return data.isEmpty ? nil : data
    }
}
