import Foundation

struct FileWriter : ByteWriter {
    let file: FileHandle
    
    func write(_ data: Data) throws {
        file.write(data) // TODO: replace with contentsOf: version
    }
}
