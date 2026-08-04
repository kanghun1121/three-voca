import Foundation

import DomainInterface

import Dependencies

extension DeleteAccountUseCase: DependencyKey {
    public static let liveValue = DeleteAccountUseCase(
        execute: {
            @Dependency(\.authSessionRepository) var authSessionRepository
            try await authSessionRepository.deleteAccount()
        }
    )
}
