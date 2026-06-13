import Foundation

import Core
import DomainInterface

import Dependencies

private actor AccessTokenStore {
    var value: String?
    func set(_ token: String) { value = token }
    func clear() { value = nil }
}

extension AuthSessionClient: DependencyKey {
    public static let liveValue: AuthSessionClient = {
        let store = AccessTokenStore()
        let keychain = KeychainClient.live
        let (stream, continuation) = AsyncStream<AuthState>.makeStream()
        return AuthSessionClient(
            getAccessToken: { await store.value },
            setAccessToken: {
                await store.set($0)
                continuation.yield(.authenticated)
            },
            getRefreshToken: { try keychain.load(.refreshToken) },
            setRefreshToken: { try keychain.save(.refreshToken, $0) },
            clearSession: {
                await store.clear()
                // yield 먼저 — keychain.delete 실패 시에도 stream이 막히지 않도록
                continuation.yield(.unauthenticated)
                try keychain.delete(.refreshToken)
            },
            authStateStream: { stream }
        )
    }()
}
