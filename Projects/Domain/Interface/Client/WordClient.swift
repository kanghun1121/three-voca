import Dependencies
import Foundation

public struct WordClient: Sendable {
    public var fetchWordDetail: @Sendable (_ id: String) async throws -> WordDetail

    public init(fetchWordDetail: @escaping @Sendable (_ id: String) async throws -> WordDetail) {
        self.fetchWordDetail = fetchWordDetail
    }
}

extension WordClient: TestDependencyKey {
    public static let testValue = WordClient(
        fetchWordDetail: unimplemented("\(Self.self).fetchWordDetail")
    )

    public static let previewValue = WordClient(
        fetchWordDetail: { _ in .previewFixture }
    )
}

public extension DependencyValues {
    var wordClient: WordClient {
        get { self[WordClient.self] }
        set { self[WordClient.self] = newValue }
    }
}
