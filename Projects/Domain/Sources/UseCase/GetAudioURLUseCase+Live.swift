import Foundation

import DomainInterface

import Dependencies

extension GetAudioURLUseCase: DependencyKey {
    public static let liveValue = GetAudioURLUseCase(
        execute: { term in
            @Dependency(\.audioRepository) var audioRepository
            return await audioRepository.audioURL(term)
        }
    )
}
