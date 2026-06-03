import Dependencies
import Foundation

public struct WordClient: Sendable {
    public var fetchWordDetail: @Sendable (_ id: String) async throws -> WordDetail
    public var prefetchWordDetails: @Sendable (_ ids: [String]) async -> Void

    public init(
        fetchWordDetail: @escaping @Sendable (_ id: String) async throws -> WordDetail,
        prefetchWordDetails: @escaping @Sendable (_ ids: [String]) async -> Void
    ) {
        self.fetchWordDetail = fetchWordDetail
        self.prefetchWordDetails = prefetchWordDetails
    }
}

extension WordClient: TestDependencyKey {
    public static let testValue = WordClient(
        fetchWordDetail: unimplemented("\(Self.self).fetchWordDetail"),
        prefetchWordDetails: unimplemented("\(Self.self).prefetchWordDetails", placeholder: ())
    )

    public static let previewValue = WordClient(
        fetchWordDetail: { _ in .previewFixture },
        prefetchWordDetails: { _ in }
    )
}

public extension DependencyValues {
    var wordClient: WordClient {
        get { self[WordClient.self] }
        set { self[WordClient.self] = newValue }
    }
}
