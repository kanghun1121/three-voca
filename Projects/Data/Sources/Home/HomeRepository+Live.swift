import Foundation

import DomainInterface
import NetworkingInterface

import Dependencies

extension HomeRepository: DependencyKey {
    public static let liveValue = HomeRepository(
        fetchHomeOverview: {
            @Dependency(\.httpClient) var httpClient
            let request = GetAllLevelsWithSessionsRequest()
            let dto: VocabularyLibraryResponseDTO = try await httpClient.request(request)
            return dto.toDomain()
        }
    )
}
