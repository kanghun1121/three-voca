import Foundation

import Dependencies

/// 홈 화면의 학습 히트맵 데이터를 조회하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct GetHeatmapDataUseCase: Sendable {
    public var execute: @Sendable () async throws -> [DailyActivity]

    public init(execute: @escaping @Sendable () async throws -> [DailyActivity]) {
        self.execute = execute
    }
}

extension GetHeatmapDataUseCase: TestDependencyKey {
    public static let testValue = GetHeatmapDataUseCase(
        execute: unimplemented("\(Self.self).execute")
    )

    public static let previewValue = GetHeatmapDataUseCase(
        execute: { DailyActivity.previewFixture }
    )
}

public extension DependencyValues {
    var getHeatmapDataUseCase: GetHeatmapDataUseCase {
        get { self[GetHeatmapDataUseCase.self] }
        set { self[GetHeatmapDataUseCase.self] = newValue }
    }
}
