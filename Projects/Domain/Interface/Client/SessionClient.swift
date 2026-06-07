import Foundation

import Dependencies

public struct SessionClient: Sendable {
    public var fetchSessionDetail: @Sendable (_ id: String) async throws -> Session

    public init(fetchSessionDetail: @escaping @Sendable (_ id: String) async throws -> Session) {
        self.fetchSessionDetail = fetchSessionDetail
    }
}

extension SessionClient: TestDependencyKey {
    public static let testValue = SessionClient(
        fetchSessionDetail: unimplemented("\(Self.self).fetchSessionDetail")
    )

    public static let previewValue = SessionClient(
        fetchSessionDetail: { id in .previewWithRecord(id: id) }
    )
}

public extension DependencyValues {
    var sessionClient: SessionClient {
        get { self[SessionClient.self] }
        set { self[SessionClient.self] = newValue }
    }
}
