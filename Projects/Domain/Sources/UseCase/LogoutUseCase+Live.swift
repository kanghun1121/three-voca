import Foundation

import DomainInterface

import Dependencies

extension LogoutUseCase: DependencyKey {
    public static let liveValue = LogoutUseCase(
        execute: {
            @Dependency(\.authSessionRepository) var authSessionRepository
            try await authSessionRepository.clearSession()
        }
    )
}
