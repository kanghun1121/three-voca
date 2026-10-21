import Foundation

import DomainInterface

import Dependencies

extension CheckAuthSessionUseCase: DependencyKey {
    public static let liveValue = CheckAuthSessionUseCase(
        execute: {
            @Dependency(\.authSessionRepository) var authSessionRepository
            return (try? authSessionRepository.getRefreshToken()) != nil
        }
    )
}
