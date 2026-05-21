import Core
import Dependencies
import DomainInterface
import Foundation

extension HomeClient: DependencyKey {
    public static let liveValue = HomeClient(
        fetchHomeOverview: {
            let client = HTTPClient()
            let request = GetAllLevelsWithSessionsRequest()
            let dto: VocabularyLibraryResponseDTO = try await client.request(request, accessToken: nil)
            return dto.toDomain()
        }
    )
}
