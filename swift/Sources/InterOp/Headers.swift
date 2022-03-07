import Foundation

struct Headers : Sequence {
    private var headers: [Header]
    
    init(_ headers: Header...) {
        self.headers = headers
    }
    
    init(_ headers: [Header]) {
        self.headers = headers
    }
    
    func makeIterator() -> IndexingIterator<[Header]> {
        return headers.makeIterator()
    }
    
    subscript(headerName: String) -> String? {
        get {
            guard let index = indexOfName(headerName) else { return nil }
            return headers[index].value
        }
        set(value) {
            if value == nil {
                delete(headerName)
                return
            }
            guard let index = indexOfName(headerName) else {
                add(headerName, value!)
                return
            }
            delete(headerName)
            headers.insert(Header(headerName, value!), at: index)
        }
    }
    
    mutating func set(_ name: String, _ value: String?) { self[name] = value }
    func get(_ headerName: String) -> String? { return self[headerName] }
    
    func getAll(_ headerName: String) -> [String] {
        let canonicalName = Header.canonicalizeName(headerName)
        return headers
            .filter { $0.name == canonicalName }
            .map(\.value)
    }
    
    mutating func add(_ header: Header) { headers.append(header) }
    mutating func add(_ name: String, _ value: String) { add(Header(name, value)) }
    
    mutating func delete(_ headerName: String) {
        let canonicalName = Header.canonicalizeName(headerName)
        self.headers = headers.filter { $0.name != canonicalName }
    }
    
    private func indexOfName(_ headerName: String) -> Int? {
        let canonicalName = Header.canonicalizeName(headerName)
        return headers.firstIndex { $0.name == canonicalName }
    }
}
