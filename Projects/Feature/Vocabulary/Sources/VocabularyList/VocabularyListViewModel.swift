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
    private let sessionID: String

    public init(sessionID: String) {
        self.sessionID = sessionID
    }

    public func load() async {
        viewState = .loading
        do {
            let session = try await sessionClient.fetchSessionDetail(sessionID)
            viewState = .loaded(session.toVocabularyListPresentationModel())
        } catch {
            viewState = .error("단어 목록을 불러오지 못했습니다.")
        }
    }

    public func wordTapped(id: String) {
        destination = .wordDetail(WordDetailViewModel(wordID: id))
    }
}
