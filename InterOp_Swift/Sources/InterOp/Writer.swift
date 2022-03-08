import Foundation

public protocol Writer {
    func write(_: Message) async throws
}
