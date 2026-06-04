import Foundation

actor AudioCache {
    private var storage: [String: URL] = [:]

    func get(_ term: String) -> URL? {
        storage[term]
    }

    func set(_ term: String, _ url: URL) {
        storage[term] = url
    }
}
