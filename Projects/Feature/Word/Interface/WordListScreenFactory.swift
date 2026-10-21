import SwiftUI

import Dependencies

/// 다른 Feature가 단어 목록 화면을 열 때 쓰는 진입 계약. 구현체는 FeatureWord가 제공한다.
public protocol WordListScreenFactory: Sendable {
    @MainActor func makeScreen(lessonID: String) -> AnyView
}

/// 구현체가 주입되지 않은 환경(Example, 프리뷰, 테스트)에서 쓰는 빈 화면.
public struct PlaceholderWordListScreenFactory: WordListScreenFactory {
    public init() {}

    @MainActor
    public func makeScreen(lessonID: String) -> AnyView {
        AnyView(EmptyView())
    }
}

public enum WordListScreenFactoryKey: TestDependencyKey {
    public static let testValue: any WordListScreenFactory = PlaceholderWordListScreenFactory()
    public static let previewValue: any WordListScreenFactory = PlaceholderWordListScreenFactory()
}

public extension DependencyValues {
    var wordListScreenFactory: any WordListScreenFactory {
        get { self[WordListScreenFactoryKey.self] }
        set { self[WordListScreenFactoryKey.self] = newValue }
    }
}
