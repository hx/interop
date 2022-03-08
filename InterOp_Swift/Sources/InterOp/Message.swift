import Foundation

public protocol Message {
    func getHeader(_ headerName: String) -> String?
    func getHeaders(_ headerName: String) -> [String]
    func getAllHeaders() -> Headers
    var body: Data { get }
}
