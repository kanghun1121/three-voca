import Dependencies
import DomainInterface
import Foundation

@Observable
@MainActor
public final class SessionDetailViewModel {
    enum ViewState {
        case loading
        case loaded(SessionDetailPresentationModel)
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
            viewState = .loaded(session.toSessionDetailPresentationModel())
        } catch {
            viewState = .error("세션 정보를 불러오지 못했습니다.")
        }
    }
}
