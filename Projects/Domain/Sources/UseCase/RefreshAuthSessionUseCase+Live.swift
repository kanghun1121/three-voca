import Foundation

import DomainInterface

import Dependencies

extension RefreshAuthSessionUseCase: DependencyKey {
    public static let liveValue = RefreshAuthSessionUseCase(
        execute: {
            @Dependency(\.authSessionRepository) var authSessionRepository
            _ = await authSessionRepository.refreshAccessToken()
        }
    )
}
