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
        return AuthSessionClient(
            getAccessToken: { await store.value },
            setAccessToken: { await store.set($0) },
            getRefreshToken: { try keychain.load(.refreshToken) },
            setRefreshToken: { try keychain.save(.refreshToken, $0) },
            clearSession: {
                await store.clear()
                try keychain.delete(.refreshToken)
            }
        )
    }()
}
