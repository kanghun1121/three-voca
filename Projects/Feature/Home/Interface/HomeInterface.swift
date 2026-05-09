import Foundation

// MARK: - Feature/Home의 public API

public protocol HomeInterface {
    // TODO: define public API
}

// MARK: - UseCase / Repository protocols
// 이 모듈에서는 UseCase/Repository protocol도 Interface에 위치한다 (사용자 결정).
//
// public protocol HomeUseCase {
//     func loadHome() async throws -> HomeModel
// }
//
// public protocol HomeRepository {
//     func fetchHome() async throws -> HomeModel
// }
//
// public struct HomeModel: Equatable, Sendable { ... }
