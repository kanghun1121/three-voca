import Foundation

import Core
import DomainInterface

import Dependencies

extension SessionClient: DependencyKey {
    public static let liveValue: SessionClient = {
        let authSessionClient = AuthSessionClient.liveValue
        let http = HTTPClient(interceptor: TokenRefreshInterceptor(authSessionClient: authSessionClient))
        return SessionClient(
            fetchSessionDetail: { id in
                let request = GetSessionDetailRequest(sessionID: id)
                let dto: SessionDetailResponseDTO = try await http.request(request)
                return dto.toDomain()
            }
        )
    }()
}
