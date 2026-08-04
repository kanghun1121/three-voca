import Foundation

import Dependencies

/// 오디오를 재생하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct PlayAudioUseCase: Sendable {
    public var execute: @Sendable (_ url: URL) async -> Void

    public init(execute: @escaping @Sendable (_ url: URL) async -> Void) {
        self.execute = execute
    }
}

extension PlayAudioUseCase: TestDependencyKey {
    public static let testValue = PlayAudioUseCase(
        execute: unimplemented("\(Self.self).execute", placeholder: ())
    )

    public static let previewValue = PlayAudioUseCase(
        execute: { _ in }
    )
}

public extension DependencyValues {
    var playAudioUseCase: PlayAudioUseCase {
        get { self[PlayAudioUseCase.self] }
        set { self[PlayAudioUseCase.self] = newValue }
    }
}
