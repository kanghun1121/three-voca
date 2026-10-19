import SwiftUI

import DesignSystem
import FeatureChatBotInterface
import FeatureChunkReaderInterface

import Dependencies
import SwiftUINavigation

public struct WordDetailView: View {
    @Bindable private var viewModel: WordDetailViewModel
    @Dependency(\.chunkReaderScreenFactory) private var chunkReaderScreenFactory
    @Dependency(\.chatBotScreenFactory) private var chatBotScreenFactory

    public init(viewModel: WordDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { geometry in
            TabView(selection: $viewModel.currentIndex) {
                ForEach(viewModel.wordIDs.indices, id: \.self) { index in
                    WordDetailPageView(
                        viewState: viewModel.viewStates[index],
                        topInset: geometry.safeAreaInsets.top,
                        onPronunciationTapped: viewModel.pronunciationTapped,
                        onChunkReaderTapped: viewModel.didTapChunkReader,
                        onChatBotTapped: viewModel.didTapChatBot
                    )
                    .tag(index)
                    .task { await viewModel.requestIfNeeded(at: index) }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(DesignSystemColor.Background.base)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $viewModel.destination.chunkReader) { route in
            chunkReaderScreenFactory.makeScreen(route: route.wrappedValue)
        }
        .navigationDestination(item: $viewModel.destination.chatBot) { context in
            chatBotScreenFactory.makeScreen(context: context.wrappedValue)
        }
    }
}
