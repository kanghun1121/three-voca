import Foundation

import Dependencies

/// 단어 상세 조회 API를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
public struct WordRepository: Sendable {
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

extension WordRepository: TestDependencyKey {
    public static let testValue = WordRepository(
        fetchWordDetail: unimplemented("\(Self.self).fetchWordDetail"),
        prefetchWordDetails: unimplemented("\(Self.self).prefetchWordDetails", placeholder: ())
    )
}

public extension DependencyValues {
    var wordRepository: WordRepository {
        get { self[WordRepository.self] }
        set { self[WordRepository.self] = newValue }
    }
}
