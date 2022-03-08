import Foundation

struct FileWriter : ByteWriter {
    let file: FileHandle
    
    init(_ file: FileHandle) {
        self.file = file
    }
    
    func write(_ data: Data) throws {
        file.write(data) // TODO: replace with contentsOf: version
    }
}
