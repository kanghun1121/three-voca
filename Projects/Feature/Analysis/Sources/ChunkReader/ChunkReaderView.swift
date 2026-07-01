import SwiftUI

import DesignSystem

public struct ChunkReaderView: View {
    @Bindable private var viewModel: ChunkReaderViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: ChunkReaderViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ChunkReaderSentenceView(
                    chunks: viewModel.presentationModel.chunks,
                    selectedChunkID: viewModel.selectedChunkID,
                    onChunkTapped: viewModel.didTapChunk
                )

                Divider()
                    .background(DesignSystemAsset.borderSubtle.swiftUIColor)
                    .padding(.vertical, 4)

                ChunkReaderWordListView(words: viewModel.presentationModel.words)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
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
            ToolbarItem(placement: .principal) {
                Text("끊어읽기")
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                    .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Text("의미 단위")
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 12))
                    .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
            }
        }
    }
}
