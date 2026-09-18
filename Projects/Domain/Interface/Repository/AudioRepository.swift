import Foundation

import Core

import Dependencies
import DependenciesMacros

/// 단어 발음 mp3 리소스를 추상화한 포트. 실제 구현은 Data 모듈에서 제공한다.
@DependencyClient
public struct AudioRepository: Sendable {
    public var prefetch: @Sendable (_ words: [(term: String, audioUrl: String)]) async -> Void
    public var fetchURL: @Sendable (_ term: String, _ audioUrl: String) async -> URL?
    public var url: @Sendable (_ term: String) async -> URL?
}

extension AudioRepository: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var audioRepository: AudioRepository {
        get { self[AudioRepository.self] }
        set { self[AudioRepository.self] = newValue }
    }
}
