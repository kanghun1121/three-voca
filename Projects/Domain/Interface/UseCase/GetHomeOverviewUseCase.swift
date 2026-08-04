import Foundation

import Dependencies

/// 홈 화면의 레벨/세션 진행 현황을 조회하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct GetHomeOverviewUseCase: Sendable {
    public var execute: @Sendable () async throws -> VocabularyLibrary

    public init(execute: @escaping @Sendable () async throws -> VocabularyLibrary) {
        self.execute = execute
    }
}

extension GetHomeOverviewUseCase: TestDependencyKey {
    public static let testValue = GetHomeOverviewUseCase(
        execute: unimplemented("\(Self.self).execute")
    )

    public static let previewValue = GetHomeOverviewUseCase(
        execute: { .previewFixture }
    )
}

public extension DependencyValues {
    var getHomeOverviewUseCase: GetHomeOverviewUseCase {
        get { self[GetHomeOverviewUseCase.self] }
        set { self[GetHomeOverviewUseCase.self] = newValue }
    }
}
