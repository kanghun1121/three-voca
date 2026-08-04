import Foundation

import DomainInterface

import Dependencies

extension PrefetchAudioUseCase: DependencyKey {
    public static let liveValue = PrefetchAudioUseCase(
        execute: { words in
            @Dependency(\.audioRepository) var audioRepository
            await audioRepository.prefetchAudio(words)
        }
    )
}
