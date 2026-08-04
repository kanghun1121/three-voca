import Foundation

import Dependencies

/// 여러 단어의 발음 mp3를 미리 다운로드해 캐싱하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct PrefetchAudioUseCase: Sendable {
    public var execute: @Sendable (_ words: [(term: String, audioUrl: String)]) async -> Void

    public init(execute: @escaping @Sendable (_ words: [(term: String, audioUrl: String)]) async -> Void) {
        self.execute = execute
    }
}

extension PrefetchAudioUseCase: TestDependencyKey {
    public static let testValue = PrefetchAudioUseCase(
        execute: unimplemented("\(Self.self).execute", placeholder: ())
    )

    public static let previewValue = PrefetchAudioUseCase(
        execute: { _ in }
    )
}

public extension DependencyValues {
    var prefetchAudioUseCase: PrefetchAudioUseCase {
        get { self[PrefetchAudioUseCase.self] }
        set { self[PrefetchAudioUseCase.self] = newValue }
    }
}
