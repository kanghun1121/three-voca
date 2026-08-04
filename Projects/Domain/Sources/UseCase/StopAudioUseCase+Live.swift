import Foundation

import DomainInterface

import Dependencies

extension StopAudioUseCase: DependencyKey {
    public static let liveValue = StopAudioUseCase(
        execute: {
            @Dependency(\.audioPlayerRepository) var audioPlayerRepository
            audioPlayerRepository.stop()
        }
    )
}
