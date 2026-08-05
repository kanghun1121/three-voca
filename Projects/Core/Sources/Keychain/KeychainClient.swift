import Foundation
import Security

import Dependencies

public enum KeychainKey: String {
    case refreshToken = "com.fivevoca.refreshToken"
}

public struct KeychainClient: Sendable {
    public var save: @Sendable (KeychainKey, String) throws -> Void
    public var load: @Sendable (KeychainKey) throws -> String
    public var delete: @Sendable (KeychainKey) throws -> Void

    public init(
        save: @escaping @Sendable (KeychainKey, String) throws -> Void,
        load: @escaping @Sendable (KeychainKey) throws -> String,
        delete: @escaping @Sendable (KeychainKey) throws -> Void
    ) {
        self.save = save
        self.load = load
        self.delete = delete
    }
}

extension KeychainClient: TestDependencyKey {
    public static let testValue = KeychainClient(
        save: unimplemented("\(Self.self).save"),
        load: unimplemented("\(Self.self).load"),
        delete: unimplemented("\(Self.self).delete")
    )
}

public extension DependencyValues {
    var keychainClient: KeychainClient {
        get { self[KeychainClient.self] }
        set { self[KeychainClient.self] = newValue }
    }
}

// MARK: - Live

extension KeychainClient: DependencyKey {
    public static let liveValue = KeychainClient(
        save: { key, value in
            guard let data = value.data(using: .utf8) else {
                throw KeychainError.unexpectedData
            }

            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key.rawValue
            ]
            SecItemDelete(query as CFDictionary)

            let attributes: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key.rawValue,
                kSecValueData: data
            ]
            let status = SecItemAdd(attributes as CFDictionary, nil)
            guard status == errSecSuccess else {
                throw KeychainError.keychainError(status)
            }
        },
        load: { key in
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key.rawValue,
                kSecReturnData: true,
                kSecMatchLimit: kSecMatchLimitOne
            ]
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)

            guard status == errSecSuccess else {
                if status == errSecItemNotFound {
                    throw KeychainError.itemNotFound
                }
                throw KeychainError.keychainError(status)
            }
            guard let data = result as? Data, let string = String(data: data, encoding: .utf8) else {
                throw KeychainError.unexpectedData
            }
            return string
        },
        delete: { key in
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: key.rawValue
            ]
            let status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess || status == errSecItemNotFound else {
                throw KeychainError.keychainError(status)
            }
        }
    )
}
