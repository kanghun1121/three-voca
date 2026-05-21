import Core
import Dependencies
import DomainInterface
import Foundation

extension SessionClient: DependencyKey {
    public static let liveValue = SessionClient(
        fetchSessionDetail: { id in
            let client = HTTPClient()
            let request = GetSessionDetailRequest(sessionID: id)
            let dto: SessionDetailResponseDTO = try await client.request(request, accessToken: nil)
            return dto.toDomain()
        }
    )
}
