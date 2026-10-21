import SwiftUI

import Dependencies

/// 다른 Feature가 Lesson 화면을 열 때 쓰는 진입 계약. 구현체는 FeatureLesson이 제공한다.
public protocol LessonScreenFactory: Sendable {
    @MainActor func makeLessonDetailScreen(lessonID: String) -> AnyView
    @MainActor func makeLearningLibraryScreen() -> AnyView
}

/// 구현체가 주입되지 않은 환경(Example, 프리뷰, 테스트)에서 쓰는 빈 화면.
public struct PlaceholderLessonScreenFactory: LessonScreenFactory {
    public init() {}

    @MainActor
    public func makeLessonDetailScreen(lessonID: String) -> AnyView {
        AnyView(EmptyView())
    }

    @MainActor
    public func makeLearningLibraryScreen() -> AnyView {
        AnyView(EmptyView())
    }
}

public enum LessonScreenFactoryKey: TestDependencyKey {
    public static let testValue: any LessonScreenFactory = PlaceholderLessonScreenFactory()
    public static let previewValue: any LessonScreenFactory = PlaceholderLessonScreenFactory()
}

public extension DependencyValues {
    var lessonScreenFactory: any LessonScreenFactory {
        get { self[LessonScreenFactoryKey.self] }
        set { self[LessonScreenFactoryKey.self] = newValue }
    }
}
