import Foundation

import Core

import Dependencies
import DependenciesMacros

/// `LearningLibrary`(및 관련 통계) 관련 API를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
@DependencyClient
public struct LearningLibraryRepository: Sendable {
    public var stream: @Sendable () -> AsyncStream<LearningLibrary> = { AsyncStream { $0.finish() } }
    public var refresh: @Sendable () async throws -> Void
}

extension LearningLibraryRepository: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var learningLibraryRepository: LearningLibraryRepository {
        get { self[LearningLibraryRepository.self] }
        set { self[LearningLibraryRepository.self] = newValue }
    }
}
