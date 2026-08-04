import Foundation

import Dependencies

/// 로컬 오디오 재생(AVFoundation)을 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
public struct AudioPlayerRepository: Sendable {
    public var play: @Sendable (_ url: URL) async -> Void
    public var stop: @Sendable () -> Void

    public init(
        play: @escaping @Sendable (_ url: URL) async -> Void,
        stop: @escaping @Sendable () -> Void
    ) {
        self.play = play
        self.stop = stop
    }
}

extension AudioPlayerRepository: TestDependencyKey {
    public static let testValue = AudioPlayerRepository(
        play: unimplemented("\(Self.self).play", placeholder: ()),
        stop: unimplemented("\(Self.self).stop")
    )
}

public extension DependencyValues {
    var audioPlayerRepository: AudioPlayerRepository {
        get { self[AudioPlayerRepository.self] }
        set { self[AudioPlayerRepository.self] = newValue }
    }
}
