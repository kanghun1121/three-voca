import Foundation

import FeatureVocaInterface

@Observable
@MainActor
public final class SessionDetailViewModel {
    private(set) var state: SessionDetailViewState?
    private(set) var isLoading: Bool = true
    private(set) var errorMessage: String?

    private let repository: SessionRepository
    private let sessionID: String

    public init(sessionID: String, repository: SessionRepository) {
        self.sessionID = sessionID
        self.repository = repository
    }

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let session = try await repository.fetchSessionDetail(id: sessionID)
            state = session.toSessionDetailViewState()
        } catch {
            errorMessage = "세션 정보를 불러오지 못했습니다."
        }
    }
}
