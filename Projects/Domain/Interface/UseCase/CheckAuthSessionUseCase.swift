import Foundation

import Core

import Dependencies
import DependenciesMacros

/// 저장된 refresh token 존재 여부로 로그인 상태를 판별하는 UseCase. ViewModel은 Repository가 아닌 이 UseCase를 통해서만 호출한다.
@DependencyClient
public struct CheckAuthSessionUseCase: Sendable {
    public var execute: @Sendable () -> Bool = { false }
}

extension CheckAuthSessionUseCase: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var checkAuthSessionUseCase: CheckAuthSessionUseCase {
        get { self[CheckAuthSessionUseCase.self] }
        set { self[CheckAuthSessionUseCase.self] = newValue }
    }
}
