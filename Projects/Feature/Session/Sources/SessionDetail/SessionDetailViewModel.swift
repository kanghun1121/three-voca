import Dependencies
import DomainInterface
import Foundation

@Observable
@MainActor
public final class SessionDetailViewModel {
    private(set) var state: SessionDetailViewState?
    private(set) var isLoading: Bool = true
    private(set) var errorMessage: String?

    @ObservationIgnored @Dependency(\.sessionClient) private var sessionClient
    private let sessionID: String

    public init(sessionID: String) {
        self.sessionID = sessionID
    }

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let session = try await sessionClient.fetchSessionDetail(sessionID)
            state = session.toSessionDetailViewState()
        } catch {
            errorMessage = "세션 정보를 불러오지 못했습니다."
        }
    }
}
