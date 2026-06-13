import Foundation

import Core
import DomainInterface

import Dependencies

extension HomeClient: DependencyKey {
    public static let liveValue: HomeClient = {
        let authSessionClient = AuthSessionClient.liveValue
        let client = HTTPClient(interceptor: TokenRefreshInterceptor(authSessionClient: authSessionClient))
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
