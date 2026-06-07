import Foundation

import Core
import DomainInterface

import Dependencies

extension SessionClient: DependencyKey {
    public static let liveValue: SessionClient = {
        let http = HTTPClient()
        return SessionClient(
            fetchSessionDetail: { id in
                let request = GetSessionDetailRequest(sessionID: id)
                let dto: SessionDetailResponseDTO = try await http.request(request)
                return dto.toDomain()
            }
        )
    }()
}
