import Foundation

import Core

import Dependencies
import DependenciesMacros

/// 레슨 콘텐츠(단어 목록 등) 조회 API를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
@DependencyClient
public struct LessonRepository: Sendable {
    public var fetchDetail: @Sendable (_ id: String) async throws -> Lesson
}

extension LessonRepository: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var lessonRepository: LessonRepository {
        get { self[LessonRepository.self] }
        set { self[LessonRepository.self] = newValue }
    }
}
