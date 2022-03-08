import Foundation

class DataReadWriter : ByteReader, ByteWriter {
    var data: Data
    var readChunkSize: Int?
    private var cursor = 0
    
    init(_ data: Data = Data(), readChunkSize: Int? = 1024) {
        self.data = data
        self.readChunkSize = readChunkSize
    }
    
    func read() throws -> Data? {
        guard cursor < data.count else {
            return nil
        }
        let result = readChunkSize == nil ?
        data[cursor...] :
        data[cursor..<min(data.count, cursor + readChunkSize!)]
        cursor += result.count
        return result
    }
    
    func write(_ data: Data) throws {
        self.data.append(data)
    }
    
    func rewind() {
        cursor = 0
    }
}
