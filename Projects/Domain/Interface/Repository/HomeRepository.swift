import Foundation

import Dependencies

/// 홈 화면 관련 API를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
public struct HomeRepository: Sendable {
    public var fetchHomeOverview: @Sendable () async throws -> VocabularyLibrary

    public init(fetchHomeOverview: @escaping @Sendable () async throws -> VocabularyLibrary) {
        self.fetchHomeOverview = fetchHomeOverview
    }
}

extension HomeRepository: TestDependencyKey {
    public static let testValue = HomeRepository(
        fetchHomeOverview: unimplemented("\(Self.self).fetchHomeOverview")
    )
}

public extension DependencyValues {
    var homeRepository: HomeRepository {
        get { self[HomeRepository.self] }
        set { self[HomeRepository.self] = newValue }
    }
}
