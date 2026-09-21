import Foundation

import Core

import Dependencies
import DependenciesMacros

/// 단어 상세 조회 API를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
@DependencyClient
public struct WordRepository: Sendable {
    public var fetchDetail: @Sendable (_ id: String) async throws -> WordDetail
    public var prefetchDetails: @Sendable (_ ids: [String]) async -> Void
}

extension WordRepository: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var wordRepository: WordRepository {
        get { self[WordRepository.self] }
        set { self[WordRepository.self] = newValue }
    }
}
