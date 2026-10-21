import Foundation

public enum KeychainError: Error, Equatable {
    case itemNotFound
    case unexpectedData
    case keychainError(OSStatus)
}
