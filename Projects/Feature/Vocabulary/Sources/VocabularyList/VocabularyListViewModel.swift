import Dependencies
import DomainInterface
import Foundation
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
    }

    private(set) var viewState: ViewState = .loading
    var destination: Destination?

    @ObservationIgnored @Dependency(\.sessionClient) private var sessionClient
    @ObservationIgnored @Dependency(\.wordClient) private var wordClient
    private let sessionID: String

    public init(sessionID: String) {
        self.sessionID = sessionID
    }

    public func load() async {
        viewState = .loading
        do {
            let session = try await sessionClient.fetchSessionDetail(sessionID)
            viewState = .loaded(session.toVocabularyListPresentationModel())
            let wordIDs = session.words.map(\.id)
            Task { await wordClient.prefetchWordDetails(wordIDs) }
        } catch {
            viewState = .error("단어 목록을 불러오지 못했습니다.")
        }
    }

    public func didTapWord(id: String) {
        guard case .loaded(let state) = viewState else { return }
        let wordIDs = state.words.map(\.id)
        guard let index = wordIDs.firstIndex(of: id) else { return }
        destination = .wordDetail(WordDetailViewModel(wordIDs: wordIDs, initialIndex: index))
    }
}
