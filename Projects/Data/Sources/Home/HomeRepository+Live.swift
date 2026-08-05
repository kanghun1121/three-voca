import Foundation

import DomainInterface
import NetworkingInterface

import Dependencies

extension HomeRepository: DependencyKey {
    public static let liveValue = HomeRepository(
        fetchHomeOverview: {
            @Dependency(\.authenticatedHTTPClient) var client
            let request = GetAllLevelsWithSessionsRequest()
            let dto: VocabularyLibraryResponseDTO = try await client.request(request)
            return dto.toDomain()
        },
        fetchHeatmapData: {
            @Dependency(\.authenticatedHTTPClient) var client
            let request = GetHeatmapDataRequest()
            let dto: HeatmapResponseDTO = try await client.request(request)
            return dto.toDomain()
        }
    )
}
