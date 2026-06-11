import Foundation

import Core
import DomainInterface

struct TokenRefreshInterceptor: HTTPInterceptor {
    let authSessionClient: AuthSessionClient

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
            let client = HTTPClient()
            let request = RefreshTokenRequest(refreshToken: refreshToken)
            let dto: AuthTokenResponseDTO = try await client.request(request)
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
