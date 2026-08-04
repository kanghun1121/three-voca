import Foundation

import DomainInterface
import Networking
import NetworkingInterface

import Dependencies

extension HomeRepository: DependencyKey {
    public static let liveValue = HomeRepository(
        fetchHomeOverview: {
            let client = HTTPClient(interceptor: TokenRefreshInterceptor())
            let request = GetAllLevelsWithSessionsRequest()
            let dto: VocabularyLibraryResponseDTO = try await client.request(request)
            return dto.toDomain()
        },
        fetchHeatmapData: {
            let client = HTTPClient(interceptor: TokenRefreshInterceptor())
            let request = GetHeatmapDataRequest()
            let dto: HeatmapResponseDTO = try await client.request(request)
            return dto.toDomain()
        }
    )
}
