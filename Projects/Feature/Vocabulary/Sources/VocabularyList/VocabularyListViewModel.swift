import Foundation

import DomainInterface

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
    }

    private(set) var viewState: ViewState = .loading
    var destination: Destination?

    @ObservationIgnored @Dependency(\.getSessionDetailUseCase) private var getSessionDetailUseCase
    @ObservationIgnored @Dependency(\.prefetchWordDetailsUseCase) private var prefetchWordDetailsUseCase
    private let sessionID: String

    public init(sessionID: String) {
        self.sessionID = sessionID
    }

    public func load() async {
        viewState = .loading
        do {
            let session = try await getSessionDetailUseCase.execute(sessionID)
            viewState = .loaded(session.toVocabularyListPresentationModel())
            let wordIDs = session.words.map(\.id)
            // 오디오 캐싱은 SessionDetailViewModel 진입 시점에 이미 시작되므로 여기서 중복 호출하지 않는다.
            Task { await prefetchWordDetailsUseCase.execute(wordIDs) }
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

}
