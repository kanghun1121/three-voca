import Foundation

import Dependencies

/// 오디오 재생을 정지하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct StopAudioUseCase: Sendable {
    public var execute: @Sendable () -> Void

    public init(execute: @escaping @Sendable () -> Void) {
        self.execute = execute
    }
}

extension StopAudioUseCase: TestDependencyKey {
    public static let testValue = StopAudioUseCase(
        execute: unimplemented("\(Self.self).execute")
    )

    public static let previewValue = StopAudioUseCase(
        execute: {}
    )
}

public extension DependencyValues {
    var stopAudioUseCase: StopAudioUseCase {
        get { self[StopAudioUseCase.self] }
        set { self[StopAudioUseCase.self] = newValue }
    }
}
