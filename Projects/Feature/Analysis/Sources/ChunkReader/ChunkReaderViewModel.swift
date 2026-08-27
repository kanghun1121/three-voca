import Foundation

import DomainInterface

@Observable
@MainActor
public final class ChunkReaderViewModel {
    let chunks: [Indexed<WordDetail.Example.Chunk>]
    let words: [Indexed<WordDetail.Example.Word>]
    var selectedChunkID: Int?

    public init(chunks: [WordDetail.Example.Chunk], words: [WordDetail.Example.Word]) {
        self.chunks = chunks.indexed()
        self.words = words.indexed()
        self.selectedChunkID = self.chunks.first?.id
    }

    func didTapChunk(id: Int) {
        selectedChunkID = (selectedChunkID == id) ? nil : id
    }
}
