import DomainInterface

actor WordDetailCache {
    private var storage: [String: WordDetail] = [:]

    func get(_ id: String) -> WordDetail? {
        storage[id]
    }

    func set(_ id: String, _ value: WordDetail) {
        storage[id] = value
    }
}
