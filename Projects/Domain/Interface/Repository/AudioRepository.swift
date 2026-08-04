import Foundation

import Dependencies

/// 단어 발음 mp3 리소스를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
public struct AudioRepository: Sendable {
    public var prefetchAudio: @Sendable (_ words: [(term: String, audioUrl: String)]) async -> Void
    public var audioURL: @Sendable (_ term: String) async -> URL?

    public init(
        prefetchAudio: @escaping @Sendable (_ words: [(term: String, audioUrl: String)]) async -> Void,
        audioURL: @escaping @Sendable (_ term: String) async -> URL?
    ) {
        self.prefetchAudio = prefetchAudio
        self.audioURL = audioURL
    }
}

extension AudioRepository: TestDependencyKey {
    public static let testValue = AudioRepository(
        prefetchAudio: unimplemented("\(Self.self).prefetchAudio", placeholder: ()),
        audioURL: unimplemented("\(Self.self).audioURL", placeholder: nil)
    )
}

public extension DependencyValues {
    var audioRepository: AudioRepository {
        get { self[AudioRepository.self] }
        set { self[AudioRepository.self] = newValue }
    }
}
