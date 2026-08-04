import Foundation

import Dependencies

public struct HomeClient: Sendable {
    public var fetchHomeOverview: @Sendable () async throws -> VocabularyLibrary
    public var fetchHeatmapData: @Sendable () async throws -> [DailyActivity]

    public init(
        fetchHomeOverview: @escaping @Sendable () async throws -> VocabularyLibrary,
        fetchHeatmapData: @escaping @Sendable () async throws -> [DailyActivity]
    ) {
        self.fetchHomeOverview = fetchHomeOverview
        self.fetchHeatmapData = fetchHeatmapData
    }
}

extension HomeClient: TestDependencyKey {
    public static let testValue = HomeClient(
        fetchHomeOverview: unimplemented("\(Self.self).fetchHomeOverview"),
        fetchHeatmapData: unimplemented("\(Self.self).fetchHeatmapData")
    )

    public static let previewValue = HomeClient(
        fetchHomeOverview: { .previewFixture },
        fetchHeatmapData: { DailyActivity.previewFixture }
    )
}

public extension DependencyValues {
    var homeClient: HomeClient {
        get { self[HomeClient.self] }
        set { self[HomeClient.self] = newValue }
    }
}
