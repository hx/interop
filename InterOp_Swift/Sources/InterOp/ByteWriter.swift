import Foundation

protocol ByteWriter {
    func write(_: Data) async throws
}
