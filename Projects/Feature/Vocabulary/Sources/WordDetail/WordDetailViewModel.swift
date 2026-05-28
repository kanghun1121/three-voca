import Dependencies
import DomainInterface
import Foundation

@Observable
@MainActor
public final class WordDetailViewModel {
    enum ViewState {
        case loading
        case loaded(WordDetailPresentationModel)
        case error(String)
    }

    private(set) var viewState: ViewState = .loading

    @ObservationIgnored @Dependency(\.wordClient) private var wordClient
    private let wordID: String

    public init(wordID: String) {
        self.wordID = wordID
    }

    public func load() async {
        viewState = .loading
        do {
            let detail = try await wordClient.fetchWordDetail(wordID)
            viewState = .loaded(detail.toWordDetailPresentationModel())
        } catch {
            viewState = .error("단어 정보를 불러오지 못했습니다.")
        }
    }
}
