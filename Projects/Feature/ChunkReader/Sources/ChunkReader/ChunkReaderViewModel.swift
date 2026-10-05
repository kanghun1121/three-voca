import Foundation

import DomainInterface

import Dependencies

@Observable
@MainActor
public final class ChunkReaderViewModel {
    let chunks: [Indexed<WordDetail.Example.Chunk>]
    let wordAnnotations: [Indexed<WordDetail.Example.WordAnnotation>]
    var selectedChunkID: Int?
    var isAudioErrorPresented = false

    @ObservationIgnored @Dependency(\.audioRepository) private var audioRepository
    @ObservationIgnored @Dependency(\.audioPlayerRepository) private var audioPlayerRepository
    @ObservationIgnored private var audioTask: Task<Void, Never>?

    public init(chunks: [WordDetail.Example.Chunk], wordAnnotations: [WordDetail.Example.WordAnnotation]) {
        self.chunks = chunks.indexed()
        self.wordAnnotations = wordAnnotations.indexed()
        self.selectedChunkID = self.chunks.first?.id
    }

    func didTapChunk(id: Int) {
        guard chunks.indices.contains(id) else { return }
        selectedChunkID = id
        isAudioErrorPresented = false
        audioTask?.cancel()
        audioPlayerRepository.stop()

        let text = chunks[id].element.text
        audioTask = Task { [weak self] in
            guard let self else { return }
            do {
                let url = try await audioRepository.chunkAudioURL(text)
                guard !Task.isCancelled, selectedChunkID == id else { return }
                await audioPlayerRepository.play(url)
            } catch {
                guard !Task.isCancelled else { return }
                isAudioErrorPresented = true
            }
        }
    }

    func stopAudio() {
        audioTask?.cancel()
        audioTask = nil
        audioPlayerRepository.stop()
    }
}
