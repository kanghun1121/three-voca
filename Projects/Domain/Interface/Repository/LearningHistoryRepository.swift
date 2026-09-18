import Foundation

import Core

import Dependencies
import DependenciesMacros

/// 레슨별 학습 이력(완료 기록) 조회/구독 및 완료 처리 API를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
@DependencyClient
public struct LearningHistoryRepository: Sendable {
    public var stream: @Sendable (_ lessonID: String) -> AsyncStream<LearningHistory> = { _ in
        AsyncStream { $0.finish() }
    }
    public var streamAllCompletions: @Sendable () -> AsyncStream<[LessonCompletionRecord]> = {
        AsyncStream { $0.finish() }
    }
    public var complete: @Sendable (_ lessonID: Int) async throws -> Void
}

extension LearningHistoryRepository: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var learningHistoryRepository: LearningHistoryRepository {
        get { self[LearningHistoryRepository.self] }
        set { self[LearningHistoryRepository.self] = newValue }
    }
}
