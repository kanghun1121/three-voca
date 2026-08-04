import Foundation

import DomainInterface

import Dependencies

extension PrefetchWordDetailsUseCase: DependencyKey {
    public static let liveValue = PrefetchWordDetailsUseCase(
        execute: { ids in
            @Dependency(\.wordRepository) var wordRepository
            await wordRepository.prefetchWordDetails(ids)
        }
    )
}
