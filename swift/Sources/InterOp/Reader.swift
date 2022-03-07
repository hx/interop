import Foundation

protocol Reader {
    func read() async throws -> Message?
}
