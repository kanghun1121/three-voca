import Foundation

import UseCaseInterface
import FeatureAnalysis

import Dependencies
import SwiftUINavigation

@Observable
@MainActor
public final class WordDetailViewModel {
    enum ViewState {
        case loading
        case loaded(WordDetailPresentationModel)
        case error(String)
    }

    @CasePathable
    enum Destination {
        case chunkReader(ChunkReaderViewModel)
    }

    private(set) var viewStates: [Int: ViewState] = [:]
    var currentIndex: Int
    var destination: Destination?
    let wordIDs: [String]

    @ObservationIgnored @Dependency(\.wordClient) private var wordClient
    @ObservationIgnored @Dependency(\.audioClient) private var audioClient
    @ObservationIgnored @Dependency(\.audioPlayerClient) private var audioPlayerClient

    public init(wordIDs: [String], initialIndex: Int) {
        self.wordIDs = wordIDs
        self.currentIndex = initialIndex
    }

    func pronunciationTapped(_ term: String) {
        Task { await didTapPronunciationButton(term: term) }
    }

    func didTapPronunciationButton(term: String) async {
        guard let url = await audioClient.audioURL(term) else { return }
        await audioPlayerClient.play(url)
    }

    func didTapChunkReader(example: WordDetailPresentationModel.ExampleRow) {
        guard let chunks = example.chunks, !chunks.isEmpty else { return }
        destination = .chunkReader(ChunkReaderViewModel(chunks: chunks, words: example.words ?? []))
    }

    func requestIfNeeded(at index: Int) async {
        guard wordIDs.indices.contains(index), viewStates[index] == nil else { return }
        viewStates[index] = .loading
        do {
            let detail = try await wordClient.fetchWordDetail(wordIDs[index])
            viewStates[index] = .loaded(detail.toWordDetailPresentationModel())
        } catch {
            print("[WordDetail] 단어 로드 실패 (index: \(index)):", error)
            viewStates[index] = .error("단어 정보를 불러오지 못했습니다.")
        }
    }
}
