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
        WordDetailPageView(
            viewState: viewModel.viewStates[viewModel.currentIndex],
            onPronunciationTapped: viewModel.pronunciationTapped,
            onChunkReaderTapped: viewModel.didTapChunkReader,
            onChatBotTapped: viewModel.didTapChatBot
        )
        .id(viewModel.currentIndex)
        .task(id: viewModel.currentIndex) {
            await viewModel.requestIfNeeded(at: viewModel.currentIndex)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 50)
                .onEnded { gesture in
                    let horizontalDistance = gesture.translation.width
                    guard abs(horizontalDistance) > abs(gesture.translation.height) else { return }
                    let nextIndex = viewModel.currentIndex + (horizontalDistance < 0 ? 1 : -1)
                    guard viewModel.wordIDs.indices.contains(nextIndex) else { return }
                    viewModel.currentIndex = nextIndex
                }
        )
        .navigationBarBackButtonHidden(true)
        .background(DesignSystemColor.Base.white)
        .toolbarBackground(DesignSystemColor.Base.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(
                    "뒤로",
                    systemImage: "chevron.left",
                    action: dismiss.callAsFunction
                )
                    .typography(DesignSystemTypography.Content.bodySemiBold)
                    .foregroundStyle(DesignSystemColor.Foreground.strong)
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
