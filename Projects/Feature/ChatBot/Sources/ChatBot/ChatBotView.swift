import SwiftUI

import DomainInterface

public struct ChatBotView: View {
    @State private var viewModel: ChatBotViewModel

    public init(viewModel: ChatBotViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        ChatBotContentView(viewModel: viewModel)
            .onDisappear { viewModel.onDisappear() }
            .toolbar(.hidden, for: .tabBar)
    }
}

#Preview("챗봇") {
    NavigationStack {
        ChatBotView(viewModel: ChatBotViewModel(context: .init(
            term: WordDetail.previewFixture.term,
            sentence: WordDetail.previewFixture.examples[0].en,
            levelLabel: "초급"
        )))
    }
}
