import Foundation

import UseCaseInterface

@Observable
@MainActor
public final class ChunkReaderViewModel {
    let presentationModel: ChunkReaderPresentationModel
    var selectedChunkID: Int?

    public init(chunks: [WordDetail.Example.Chunk], words: [WordDetail.Example.Word]) {
        self.presentationModel = ChunkReaderPresentationModel(chunks: chunks, words: words)
        self.selectedChunkID = presentationModel.chunks.first?.id
    }

    func didTapChunk(id: Int) {
        selectedChunkID = (selectedChunkID == id) ? nil : id
    }
}
