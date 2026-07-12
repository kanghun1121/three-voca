import SwiftUI

import DesignSystem
import FeatureAnalysis

import SwiftUINavigation

public struct WordDetailView: View {
    @Bindable private var viewModel: WordDetailViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: WordDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        TabView(selection: $viewModel.currentIndex) {
            ForEach(viewModel.wordIDs.indices, id: \.self) { index in
                WordDetailPageView(
                    viewState: viewModel.viewStates[index],
                    onPronunciationTapped: { term in
                        Task { await viewModel.didTapPronunciationButton(term: term) }
                    },
                    onChunkReaderTapped: viewModel.didTapChunkReader
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
                Button("뒤로", systemImage: "chevron.left", action: dismiss.callAsFunction)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            }
        }
        .navigationDestination(item: $viewModel.destination.chunkReader) { chunkReaderVM in
            ChunkReaderView(viewModel: chunkReaderVM)
        }
    }
}
