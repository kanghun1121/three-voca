import Foundation

import DomainInterface

import Dependencies

extension PlayAudioUseCase: DependencyKey {
    public static let liveValue = PlayAudioUseCase(
        execute: { url in
            @Dependency(\.audioPlayerRepository) var audioPlayerRepository
            await audioPlayerRepository.play(url)
        }
    )
}
