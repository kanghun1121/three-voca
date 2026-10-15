import Foundation

import Core
import NetworkingInterface

import Dependencies
import DependenciesMacros

/// 서버에서 시드 데이터 전체를 받아온다. 인증이 필요 없는 공개 RPC라 무인증 `httpClient`를 쓴다.
/// `httpClient`는 호출 시점에 읽는다 — `liveValue`가 한 번만 평가되므로 생성 시점에 캡처하면
/// 테스트가 주입한 스텁이 반영되지 않는다.
@DependencyClient
struct SeedRemoteDataSource: Sendable {
    var fetchSeedData: @Sendable () async throws -> SeedDataResponseDTO
}

extension SeedRemoteDataSource: DependencyKey {
    static let liveValue = SeedRemoteDataSource(
        fetchSeedData: {
            @Dependency(\.httpClient) var httpClient
            return try await httpClient.request(SeedDataRequest())
        }
    )
}

extension SeedRemoteDataSource: UnimplementedTestDependencyKey {}

extension DependencyValues {
    var seedRemoteDataSource: SeedRemoteDataSource {
        get { self[SeedRemoteDataSource.self] }
        set { self[SeedRemoteDataSource.self] = newValue }
    }
}
