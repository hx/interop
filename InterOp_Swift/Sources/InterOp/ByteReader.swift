import Foundation

protocol ByteReader {
    /**
     Returns one or more bytes, or `nil` if the source is EOF.
     */
    func read() throws -> Data?
}
