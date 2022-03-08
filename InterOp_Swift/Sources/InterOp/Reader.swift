import Foundation

public protocol Reader {
    func read() async throws -> Message?
}
