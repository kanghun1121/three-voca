import Foundation

import Core
import DomainInterface

import Dependencies

struct TokenRefreshInterceptor: HTTPInterceptor {
    @Dependency(\.httpClient) private var httpClient
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

        do {
            let refreshToken = try authSessionClient.getRefreshToken()
            let request = RefreshTokenRequest(refreshToken: refreshToken)
            let dto: AuthTokenResponseDTO = try await httpClient.request(request)
            let token = dto.toDomain()
            await authSessionClient.setAccessToken(token.accessToken)
            try authSessionClient.setRefreshToken(token.refreshToken)
            return true
        } catch {
            try? await authSessionClient.clearSession()
            return false
        }
    }
}
