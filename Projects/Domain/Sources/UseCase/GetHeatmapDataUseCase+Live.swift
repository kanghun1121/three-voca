import Foundation

import DomainInterface

import Dependencies

extension GetHeatmapDataUseCase: DependencyKey {
    public static let liveValue = GetHeatmapDataUseCase(
        execute: {
            @Dependency(\.homeRepository) var homeRepository
            return try await homeRepository.fetchHeatmapData()
        }
    )
}
