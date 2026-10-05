import SwiftUI

import Dependencies

/// 다른 Feature가 ChatBot 화면을 열 때 쓰는 진입 계약. 구현체는 FeatureChatBot이 제공한다.
public protocol ChatBotScreenFactory: Sendable {
    @MainActor func makeScreen(context: ChatBotContext) -> AnyView
}

/// 구현체가 주입되지 않은 환경(Example, 프리뷰, 테스트)에서 쓰는 빈 화면.
public struct PlaceholderChatBotScreenFactory: ChatBotScreenFactory {
    public init() {}

    @MainActor
    public func makeScreen(context: ChatBotContext) -> AnyView {
        AnyView(EmptyView())
    }
}

public enum ChatBotScreenFactoryKey: TestDependencyKey {
    public static let testValue: any ChatBotScreenFactory = PlaceholderChatBotScreenFactory()
    public static let previewValue: any ChatBotScreenFactory = PlaceholderChatBotScreenFactory()
}

public extension DependencyValues {
    var chatBotScreenFactory: any ChatBotScreenFactory {
        get { self[ChatBotScreenFactoryKey.self] }
        set { self[ChatBotScreenFactoryKey.self] = newValue }
    }
}
