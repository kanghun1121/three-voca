import Foundation

import Core
import DomainInterface

import Dependencies

private final class AccessTokenStore: @unchecked Sendable {
    private var _value: String?
    private let lock = NSLock()

    var value: String? {
        get { lock.withLock { _value } }
        set { lock.withLock { _value = newValue } }
    }
}

extension AuthSessionClient: DependencyKey {
    public static let liveValue: AuthSessionClient = {
        let store = AccessTokenStore()
        let keychain = KeychainClient.live
        return AuthSessionClient(
            getAccessToken: { store.value },
            setAccessToken: { store.value = $0 },
            getRefreshToken: { try keychain.load(.refreshToken) },
            setRefreshToken: { try keychain.save(.refreshToken, $0) },
            clearSession: {
                store.value = nil
                try keychain.delete(.refreshToken)
            }
        )
    }()
}
