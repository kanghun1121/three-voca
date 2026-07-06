import Foundation

import Core
import DomainInterface

import Dependencies

struct TokenRefreshInterceptor: HTTPInterceptor {
    @Dependency(\.authSessionClient) private var authSessionClient

    func adapt(_ request: URLRequest) async throws -> URLRequest {
        guard let accessToken = await authSessionClient.getAccessToken() else {
            return request
        }
        var adapted = request
        adapted.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return adapted
    }

    func retry(dueTo error: any Error, response: HTTPURLResponse?) async -> Bool {
        guard response?.statusCode == 401 else { return false }
        return await authSessionClient.refreshAccessToken()
    }
}
