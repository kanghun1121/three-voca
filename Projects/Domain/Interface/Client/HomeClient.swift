import Foundation

import Dependencies

public struct HomeClient: Sendable {
    public var fetchHomeOverview: @Sendable () async throws -> VocabularyLibrary

    public init(fetchHomeOverview: @escaping @Sendable () async throws -> VocabularyLibrary) {
        self.fetchHomeOverview = fetchHomeOverview
    }
}

extension HomeClient: TestDependencyKey {
    public static let testValue = HomeClient(
        fetchHomeOverview: unimplemented("\(Self.self).fetchHomeOverview")
    )

    public static let previewValue = HomeClient(
        fetchHomeOverview: { .previewFixture }
    )
}

public extension DependencyValues {
    var homeClient: HomeClient {
        get { self[HomeClient.self] }
        set { self[HomeClient.self] = newValue }
    }
}
