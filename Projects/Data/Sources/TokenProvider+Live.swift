import Foundation

import DomainInterface
import NetworkingInterface

import Dependencies

extension TokenProvider: DependencyKey {
    public static let liveValue = TokenProvider(
        getAccessToken: {
            @Dependency(\.authSessionRepository) var authSessionRepository
            return await authSessionRepository.getAccessToken()
        },
        refreshAccessToken: {
            @Dependency(\.authSessionRepository) var authSessionRepository
            return await authSessionRepository.refreshAccessToken()
        }
    )
}
