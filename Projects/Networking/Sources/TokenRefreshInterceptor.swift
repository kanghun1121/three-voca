import Foundation

import DomainInterface
import NetworkingInterface

import Dependencies

struct TokenRefreshInterceptor: HTTPInterceptor {
    @Dependency(\.authSessionRepository) private var authSessionRepository

    func adapt(_ request: URLRequest) async throws -> URLRequest {
        guard let accessToken = await authSessionRepository.getAccessToken() else {
            return request
        }
        var adapted = request
        adapted.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return adapted
    }

    func retry(dueTo error: any Error, response: HTTPURLResponse?) async -> Bool {
        guard response?.statusCode == 401 else { return false }
        return await authSessionRepository.refreshAccessToken()
    }
}
