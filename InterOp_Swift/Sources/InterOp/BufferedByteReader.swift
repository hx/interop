//
// Created by Neil Pearson on 6/3/2022.
//

import Foundation

class BufferedByteReader : ByteReader {
    let reader: ByteReader
    
    private var buffer = Data()
    
    init(_ reader: ByteReader) {
        self.reader = reader
    }

    func read() async throws -> Data? {
        if !buffer.isEmpty {
            return take()
        }
        return try await reader.read()
    }
    
    func readByte() async throws -> UInt8? {
        if buffer.isEmpty {
            if try await nextChunk() == nil {
                return nil
            }
        }
        return buffer.removeFirst()
    }
    
    func read(exactly n: Int) async throws -> Data? {
        var taken = take()
        while taken.count < n {
            guard let chunk = try await reader.read() else {
                throw Errors.alreadyClosed
            }
            taken.append(chunk)
        }
        taken = restore(taken, from: n)
        return taken
    }
    
    func read(until byte: UInt8, atMost byteLimit: Int = Int.max) async throws -> Data? {
        var taken = take(), check = 0
        outer: while taken.count < byteLimit || check < taken.count {
            while check < taken.count {
                if taken[check] == byte {
                    taken = restore(taken, from: check + 1)
                    break outer
                }
                check += 1
            }
            if let chunk = try await reader.read() {
                taken.append(chunk)
            } else {
                break
            }
        }
        taken = restore(taken, from: byteLimit)
        return taken.count == 0 ? nil : taken
    }
    
    func read(until character: UnicodeScalar, atMost byteLimit: Int = Int.max) async throws -> Data? {
        let byte = character.value
        if byte > 255 {
            throw Errors.expectedSingleByte
        }
        return try await read(until: UInt8(byte), atMost: byteLimit)
    }
    
    func readAll() async throws -> Data {
        var taken = take()
        while let chunk = try await reader.read() {
            taken.append(chunk)
        }
        return taken
    }
    
    private func nextChunk() async throws -> Data? {
        guard let bytes = try await reader.read() else {
            return nil
        }
        buffer.append(bytes)
        return bytes
    }
    
    /**
     Takes whatever data is in the buffer, leaving it empty.
     */
    private func take() -> Data {
        let taken = buffer
        if buffer.count > 0 {
            buffer.removeAll(keepingCapacity: true)
        }
        return taken
    }
    
    /**
     Restore unwanted data to the buffer. Returns the given data without the unwanted suffix.
     */
    private func restore(_ data: Data, from index: Int) -> Data {
        if data.count <= index {
            return data
        }
        buffer.insert(contentsOf: data[index...], at: 0)
//        buffer.append(data[index...])
        return data[..<index]
    }
}
