import Foundation

import NetworkingInterface

import Dependencies

struct TokenRefreshInterceptor: HTTPInterceptor {
    @Dependency(\.tokenProvider) private var tokenProvider

    func adapt(_ request: URLRequest) async throws -> URLRequest {
        guard let accessToken = await tokenProvider.getAccessToken() else {
            return request
        }
        var adapted = request
        adapted.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return adapted
    }

    func retry(dueTo error: any Error, response: HTTPURLResponse?) async -> Bool {
        guard response?.statusCode == 401 else { return false }
        return await tokenProvider.refreshAccessToken()
    }
}
