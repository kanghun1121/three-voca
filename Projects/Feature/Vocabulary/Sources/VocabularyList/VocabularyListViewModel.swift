import Foundation

import DomainInterface
import FeatureWordGameInterface

import Dependencies
import SwiftUINavigation

@Observable
@MainActor
public final class VocabularyListViewModel {
    enum ViewState {
        case loading
        case loaded(VocabularyListPresentationModel)
        case error(String)
    }

    @CasePathable
    enum Destination {
        case wordDetail(WordDetailViewModel)
        case wordGame(WordGameViewModel)
    }

    private(set) var viewState: ViewState = .loading
    var destination: Destination?

    @ObservationIgnored @Dependency(\.sessionClient) private var sessionClient
    @ObservationIgnored @Dependency(\.wordClient) private var wordClient
    @ObservationIgnored @Dependency(\.audioClient) private var audioClient
    private let sessionID: String
    private var sessionWords: [Session.Word] = []

    public init(sessionID: String) {
        self.sessionID = sessionID
    }

    public func load() async {
        viewState = .loading
        do {
            let session = try await sessionClient.fetchSessionDetail(sessionID)
            sessionWords = session.words
            viewState = .loaded(session.toVocabularyListPresentationModel())
            let wordIDs = session.words.map(\.id)
            let terms = session.words.map(\.term)
            Task { await wordClient.prefetchWordDetails(wordIDs) }
            Task { await audioClient.prefetchAudio(terms) }
        } catch {
            print("[VocabularyList] 세션 로드 실패:", error)
            viewState = .error("단어 목록을 불러오지 못했습니다.")
        }
    }

    public func didTapWord(id: String) {
        guard case .loaded(let state) = viewState else { return }
        let wordIDs = state.words.map(\.id)
        guard let index = wordIDs.firstIndex(of: id) else { return }
        destination = .wordDetail(WordDetailViewModel(wordIDs: wordIDs, initialIndex: index))
    }

    public func didTapGame() {
        guard !sessionWords.isEmpty else { return }
        destination = .wordGame(WordGameViewModel(words: sessionWords))
    }
}
