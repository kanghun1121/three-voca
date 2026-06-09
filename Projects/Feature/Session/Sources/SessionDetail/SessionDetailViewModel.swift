import Foundation

import DomainInterface
import FeatureVocabulary
import FeatureWordGameInterface

import Dependencies
import SwiftUINavigation

@Observable
@MainActor
public final class SessionDetailViewModel {
    enum ViewState {
        case loading
        case loaded(SessionDetailPresentationModel)
        case error(String)
    }

    @CasePathable
    public enum Destination {
        case vocabularyList(VocabularyListViewModel)
        case wordGame(RecognitionViewModel)
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
            viewState = .loaded(session.toSessionDetailPresentationModel())
        } catch {
            viewState = .error("세션 정보를 불러오지 못했습니다.")
        }
    }

    public func didTapVocabularyList() {
        destination = .vocabularyList(VocabularyListViewModel(sessionID: sessionID))
    }

    public func didTapGame() {
        destination = .wordGame(RecognitionViewModel(sessionID: sessionID))
    }
}
