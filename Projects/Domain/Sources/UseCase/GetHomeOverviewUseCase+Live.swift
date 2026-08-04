import Foundation

import DomainInterface

import Dependencies

extension GetHomeOverviewUseCase: DependencyKey {
    public static let liveValue = GetHomeOverviewUseCase(
        execute: {
            @Dependency(\.homeRepository) var homeRepository
            return try await homeRepository.fetchHomeOverview()
        }
    )
}
