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

    private(set) var viewStates: [Int: ViewState] = [:]
    var currentIndex: Int
    let wordIDs: [String]

    @ObservationIgnored @Dependency(\.wordClient) private var wordClient

    public init(wordIDs: [String], initialIndex: Int) {
        self.wordIDs = wordIDs
        self.currentIndex = initialIndex
    }

    func loadIfNeeded(at index: Int) async {
        guard wordIDs.indices.contains(index), viewStates[index] == nil else { return }
        viewStates[index] = .loading
        do {
            let detail = try await wordClient.fetchWordDetail(wordIDs[index])
            viewStates[index] = .loaded(detail.toWordDetailPresentationModel())
        } catch {
            viewStates[index] = .error("단어 정보를 불러오지 못했습니다.")
        }
    }
}
