import SwiftUI

import DesignSystem

struct ChunkReaderSentenceView: View {
    let chunks: [ChunkReaderPresentationModel.Chunk]
    let selectedChunkID: Int?
    let onChunkTapped: (Int) -> Void

    private var selectedChunk: ChunkReaderPresentationModel.Chunk? {
        chunks.first { $0.id == selectedChunkID }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("탭하면 의미가 나와요")
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 12))
                .foregroundStyle(DesignSystemAsset.fgMuted.swiftUIColor)
                .padding(.bottom, 12)

            FlowLayout(horizontalSpacing: 4, verticalSpacing: 5) {
                ForEach(chunks) { chunk in
                    ChunkView(
                        chunk: chunk,
                        isSelected: chunk.id == selectedChunkID,
                        onTap: { onChunkTapped(chunk.id) }
                    )
                }
            }

            meaningLabel
                .frame(minHeight: 26, alignment: .leading)
                .padding(.top, 16)
        }
    }

    @ViewBuilder
    private var meaningLabel: some View {
        if let selectedChunk {
            Text(selectedChunk.meaning)
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 17))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
        } else {
            Text("청크를 탭하면 뜻이 나와요")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
        }
    }
}

private struct ChunkView: View {
    let chunk: ChunkReaderPresentationModel.Chunk
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(chunk.text)
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 17))
                .foregroundStyle(DesignSystemAsset.fgStrong.swiftUIColor)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(
                    isSelected
                        ? DesignSystemAsset.chunkSelected.swiftUIColor
                        : DesignSystemAsset.chunkBg.swiftUIColor
                )
                .clipShape(.rect(cornerRadius: 8))
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(DesignSystemAsset.chunkRing.swiftUIColor, lineWidth: 2)
                    }
                }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}
