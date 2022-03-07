import Foundation

protocol Writer {
    func write(_: Message) async throws
}
