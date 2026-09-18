import Foundation

import Core

import Dependencies
import DependenciesMacros

/// 로컬 오디오 재생(AVFoundation)을 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
@DependencyClient
public struct AudioPlayerRepository: Sendable {
    public var play: @Sendable (_ url: URL) async -> Void
    public var stop: @Sendable () -> Void
}

extension AudioPlayerRepository: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var audioPlayerRepository: AudioPlayerRepository {
        get { self[AudioPlayerRepository.self] }
        set { self[AudioPlayerRepository.self] = newValue }
    }
}
