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
            ChunkReaderBadge(icon: "bolt.fill", label: "의미 단위 해석")
                .padding(.bottom, 12)

            ChunkChipsRow(
                chunks: chunks,
                selectedChunkID: selectedChunkID,
                onChunkTapped: onChunkTapped
            )

            ChunkReaderMeaningLabel(meaning: selectedChunk?.meaning)
                .frame(minHeight: 26, alignment: .leading)
                .padding(.top, 16)
        }
    }
}
