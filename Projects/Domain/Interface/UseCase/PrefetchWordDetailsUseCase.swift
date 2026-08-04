import Foundation

import Dependencies

/// 여러 단어 상세를 미리 캐싱하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct PrefetchWordDetailsUseCase: Sendable {
    public var execute: @Sendable (_ ids: [String]) async -> Void

    public init(execute: @escaping @Sendable (_ ids: [String]) async -> Void) {
        self.execute = execute
    }
}

extension PrefetchWordDetailsUseCase: TestDependencyKey {
    public static let testValue = PrefetchWordDetailsUseCase(
        execute: unimplemented("\(Self.self).execute", placeholder: ())
    )

    public static let previewValue = PrefetchWordDetailsUseCase(
        execute: { _ in }
    )
}

public extension DependencyValues {
    var prefetchWordDetailsUseCase: PrefetchWordDetailsUseCase {
        get { self[PrefetchWordDetailsUseCase.self] }
        set { self[PrefetchWordDetailsUseCase.self] = newValue }
    }
}
