import Foundation

import DomainInterface
import Networking
import NetworkingInterface

import Dependencies

extension HomeClient: DependencyKey {
    public static let liveValue: HomeClient = {
        let client = HTTPClient(interceptor: TokenRefreshInterceptor())
        return HomeClient(
            fetchHeatmapData: {
                let request = GetHeatmapDataRequest()
                let dto: HeatmapResponseDTO = try await client.request(request)
                return dto.toDomain()
            }
        )
    }()
}
