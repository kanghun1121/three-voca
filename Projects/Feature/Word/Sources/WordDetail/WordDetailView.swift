import SwiftUI

import DesignSystem
import FeatureChatBot
import FeatureChunkReader

import SwiftUINavigation

public struct WordDetailView: View {
    @Bindable private var viewModel: WordDetailViewModel
    @Environment(\.dismiss) private var dismiss

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
        .navigationDestination(item: $viewModel.destination.chunkReader) { chunkReaderVM in
            ChunkReaderView(viewModel: chunkReaderVM)
        }
        .navigationDestination(item: $viewModel.destination.chatBot) { chatBotVM in
            ChatBotView(viewModel: chatBotVM)
        }
    }
}
