import Foundation

import Dependencies

public struct SessionClient: Sendable {
    public var fetchSessionDetail: @Sendable (_ id: String) async throws -> Session
    public var completeSession: @Sendable (_ sessionID: Int) async throws -> Void

    public init(
        fetchSessionDetail: @escaping @Sendable (_ id: String) async throws -> Session,
        completeSession: @escaping @Sendable (_ sessionID: Int) async throws -> Void
    ) {
        self.fetchSessionDetail = fetchSessionDetail
        self.completeSession = completeSession
    }
}

extension SessionClient: TestDependencyKey {
    public static let testValue = SessionClient(
        fetchSessionDetail: unimplemented("\(Self.self).fetchSessionDetail"),
        completeSession: unimplemented("\(Self.self).completeSession")
    )

    public static let previewValue = SessionClient(
        fetchSessionDetail: { id in .previewWithRecord(id: id) },
        completeSession: { _ in }
    )

    public static let previewLoading = SessionClient(
        fetchSessionDetail: { _ in
            try await Task.sleep(for: .seconds(3600))
            throw CancellationError()
        },
        completeSession: { _ in }
    )
}

public extension DependencyValues {
    var sessionClient: SessionClient {
        get { self[SessionClient.self] }
        set { self[SessionClient.self] = newValue }
    }
}
