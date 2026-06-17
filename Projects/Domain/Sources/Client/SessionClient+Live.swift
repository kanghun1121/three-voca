import Foundation

import Core
import DomainInterface

import Dependencies

private actor SessionCache {
    private var store: [String: Session] = [:]

    func fetch(_ id: String) -> Session? {
        store[id]
    }

    func set(_ id: String, _ session: Session) {
        store[id] = session
    }
}

extension SessionClient: DependencyKey {
    public static let liveValue: SessionClient = {
        let authSessionClient = AuthSessionClient.liveValue
        let http = HTTPClient(interceptor: TokenRefreshInterceptor(authSessionClient: authSessionClient))
        let cache = SessionCache()
        return SessionClient(
            fetchSessionDetail: { id in
                if let cached = await cache.fetch(id) { return cached }
                let request = GetSessionDetailRequest(sessionID: id)
                let dto: SessionDetailResponseDTO = try await http.request(request)
                let session = dto.toDomain()
                await cache.set(id, session)
                return session
            },
            completeSession: { sessionID in
                let request = CompleteSessionRequest(sessionID: sessionID)
                let _: CompleteSessionResponseDTO = try await http.request(request)
            }
        )
    }()
}
