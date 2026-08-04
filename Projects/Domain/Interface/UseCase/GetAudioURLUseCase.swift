import Foundation

import Dependencies

/// 캐싱된 발음 mp3의 로컬 URL을 조회하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct GetAudioURLUseCase: Sendable {
    public var execute: @Sendable (_ term: String) async -> URL?

    public init(execute: @escaping @Sendable (_ term: String) async -> URL?) {
        self.execute = execute
    }
}

extension GetAudioURLUseCase: TestDependencyKey {
    public static let testValue = GetAudioURLUseCase(
        execute: unimplemented("\(Self.self).execute", placeholder: nil)
    )

    public static let previewValue = GetAudioURLUseCase(
        execute: { _ in nil }
    )
}

public extension DependencyValues {
    var getAudioURLUseCase: GetAudioURLUseCase {
        get { self[GetAudioURLUseCase.self] }
        set { self[GetAudioURLUseCase.self] = newValue }
    }
}
