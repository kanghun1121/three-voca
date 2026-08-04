import Foundation

import DomainInterface
import Networking
import NetworkingInterface

import Dependencies

extension HomeClient: DependencyKey {
    public static let liveValue: HomeClient = {
        let client = HTTPClient(interceptor: TokenRefreshInterceptor())
        return HomeClient(
            fetchHomeOverview: {
                let request = GetAllLevelsWithSessionsRequest()
                let dto: VocabularyLibraryResponseDTO = try await client.request(request)
                return dto.toDomain()
            },
            fetchHeatmapData: {
                let request = GetHeatmapDataRequest()
                let dto: HeatmapResponseDTO = try await client.request(request)
                return dto.toDomain()
            }
        )
    }()
}
