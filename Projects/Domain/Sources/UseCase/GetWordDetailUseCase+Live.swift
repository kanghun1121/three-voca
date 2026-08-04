import Foundation

import DomainInterface

import Dependencies

extension GetWordDetailUseCase: DependencyKey {
    public static let liveValue = GetWordDetailUseCase(
        execute: { id in
            @Dependency(\.wordRepository) var wordRepository
            return try await wordRepository.fetchWordDetail(id)
        }
    )
}
