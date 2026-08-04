import Foundation

import DomainInterface

import Dependencies

extension ObserveAuthStateUseCase: DependencyKey {
    public static let liveValue = ObserveAuthStateUseCase(
        execute: {
            @Dependency(\.authSessionRepository) var authSessionRepository
            return authSessionRepository.authStateStream()
        }
    )
}
