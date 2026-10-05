import SwiftUI

import DesignSystem
import FeatureChatBotInterface
import FeatureChunkReaderInterface

import Dependencies
import SwiftUINavigation

public struct WordDetailView: View {
    @Bindable private var viewModel: WordDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @Dependency(\.chunkReaderScreenFactory) private var chunkReaderScreenFactory
    @Dependency(\.chatBotScreenFactory) private var chatBotScreenFactory

    public init(viewModel: WordDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        TabView(selection: $viewModel.currentIndex) {
            ForEach(viewModel.wordIDs.indices, id: \.self) { index in
                WordDetailPageView(
                    viewState: viewModel.viewStates[index],
                    onPronunciationTapped: viewModel.pronunciationTapped,
                    onChunkReaderTapped: viewModel.didTapChunkReader,
                    onChatBotTapped: viewModel.didTapChatBot
                )
                .tag(index)
                .task { await viewModel.requestIfNeeded(at: index) }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(DesignSystemAsset.background.swiftUIColor)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(DesignSystemAsset.background.swiftUIColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(
                    "뒤로",
                    systemImage: "chevron.left",
                    action: dismiss.callAsFunction
                )
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            }
        }
        .navigationDestination(item: $viewModel.destination.chunkReader) { route in
            chunkReaderScreenFactory.makeScreen(route: route.wrappedValue)
        }
        .navigationDestination(item: $viewModel.destination.chatBot) { context in
            chatBotScreenFactory.makeScreen(context: context.wrappedValue)
        }
    }
}
