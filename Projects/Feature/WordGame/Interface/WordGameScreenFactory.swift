import SwiftUI

import Dependencies

/// 다른 Feature가 단어 게임 화면을 열 때 쓰는 진입 계약. 구현체는 FeatureWordGame이 제공한다.
public protocol WordGameScreenFactory: Sendable {
    @MainActor func makeScreen(lessonID: String) -> AnyView
}

/// 구현체가 주입되지 않은 환경(Example, 프리뷰, 테스트)에서 쓰는 빈 화면.
public struct PlaceholderWordGameScreenFactory: WordGameScreenFactory {
    public init() {}

    @MainActor
    public func makeScreen(lessonID: String) -> AnyView {
        AnyView(EmptyView())
    }
}

public enum WordGameScreenFactoryKey: TestDependencyKey {
    public static let testValue: any WordGameScreenFactory = PlaceholderWordGameScreenFactory()
    public static let previewValue: any WordGameScreenFactory = PlaceholderWordGameScreenFactory()
}

public extension DependencyValues {
    var wordGameScreenFactory: any WordGameScreenFactory {
        get { self[WordGameScreenFactoryKey.self] }
        set { self[WordGameScreenFactoryKey.self] = newValue }
    }
}
