import SwiftUI

import FeatureChatBotInterface

import Dependencies

public struct LiveChatBotScreenFactory: ChatBotScreenFactory {
    public init() {}

    @MainActor
    public func makeScreen(context: ChatBotContext) -> AnyView {
        AnyView(ChatBotView(viewModel: ChatBotViewModel(context: context)))
    }
}

extension ChatBotScreenFactoryKey: DependencyKey {
    public static let liveValue: any ChatBotScreenFactory = LiveChatBotScreenFactory()
}
