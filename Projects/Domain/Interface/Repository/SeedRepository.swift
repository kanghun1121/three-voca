import Foundation

import Core

import Dependencies
import DependenciesMacros

/// 서버가 원본인 시드 데이터(레벨·레슨·단어·뜻·예문·오답 선택지)를 로컬 DB로 동기화하는 포트.
/// 화면은 로컬 DB만 읽고, 서버와의 통신은 이 포트의 구현(Data 모듈)만 담당한다.
@DependencyClient
public struct SeedRepository: Sendable {
    /// 로컬 DB에 시드가 하나도 없을 때만 서버에서 받아 저장한다. 이미 있으면 아무것도 하지 않는다.
    public var syncIfNeeded: @Sendable () async throws -> Void
}

extension SeedRepository: UnimplementedTestDependencyKey {}

public extension DependencyValues {
    var seedRepository: SeedRepository {
        get { self[SeedRepository.self] }
        set { self[SeedRepository.self] = newValue }
    }
}
