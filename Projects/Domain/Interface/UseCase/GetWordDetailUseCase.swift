import Foundation

import Dependencies

/// 단어 상세를 조회하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
public struct GetWordDetailUseCase: Sendable {
    public var execute: @Sendable (_ id: String) async throws -> WordDetail

    public init(execute: @escaping @Sendable (_ id: String) async throws -> WordDetail) {
        self.execute = execute
    }
}

extension GetWordDetailUseCase: TestDependencyKey {
    public static let testValue = GetWordDetailUseCase(
        execute: unimplemented("\(Self.self).execute")
    )

    public static let previewValue = GetWordDetailUseCase(
        execute: { _ in .previewFixture }
    )
}

public extension DependencyValues {
    var getWordDetailUseCase: GetWordDetailUseCase {
        get { self[GetWordDetailUseCase.self] }
        set { self[GetWordDetailUseCase.self] = newValue }
    }
}
