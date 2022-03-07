import Foundation

struct Header {
    static let ID = "Interop-Rpc-Id",
               Class = "Interop-Rpc-Class",
               Error = "Interop-Error",
               ContentType = "Content-Type",
               ContentLength = "Content-Length"
    
    var name: String
    var value: String
    
    init(_ name: String, _ value: String) {
        self.name = Header.canonicalizeName(name)
        self.value = value
    }
    
    static func parse(_ headerLine: String) throws -> Header {
        let parts = headerLine
            .split(separator: ":", maxSplits: 2, omittingEmptySubsequences: false)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
        if parts.count != 2 {
            throw Errors.badHeader(header: headerLine)
        }
        return self.init(parts[0], parts[1])
    }
    
    static internal func canonicalizeName(_ name: String) -> String {
        return name
            .split { $0 == "-" || $0 == "_" }
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: "-")
    }
}
