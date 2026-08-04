import Foundation

import Dependencies

public struct HomeClient: Sendable {
    public var fetchHeatmapData: @Sendable () async throws -> [DailyActivity]

    public init(
        fetchHeatmapData: @escaping @Sendable () async throws -> [DailyActivity]
    ) {
        self.fetchHeatmapData = fetchHeatmapData
    }
}

extension HomeClient: TestDependencyKey {
    public static let testValue = HomeClient(
        fetchHeatmapData: unimplemented("\(Self.self).fetchHeatmapData")
    )

    public static let previewValue = HomeClient(
        fetchHeatmapData: { DailyActivity.previewFixture }
    )
}

public extension DependencyValues {
    var homeClient: HomeClient {
        get { self[HomeClient.self] }
        set { self[HomeClient.self] = newValue }
    }
}
