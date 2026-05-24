import Dependencies
import DomainInterface
import Foundation

@Observable
@MainActor
public final class VocabularyListViewModel {
    enum ViewState {
        case loading
        case loaded(VocabularyListPresentationModel)
        case error(String)
    }

    private(set) var viewState: ViewState = .loading

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
}
