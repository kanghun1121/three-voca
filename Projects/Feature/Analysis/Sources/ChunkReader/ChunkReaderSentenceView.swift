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

            ChunkReaderMeaningLabel(meaning: selectedChunk?.meaning)
                .frame(minHeight: 26, alignment: .leading)
                .padding(.top, 16)
        }
    }
}
