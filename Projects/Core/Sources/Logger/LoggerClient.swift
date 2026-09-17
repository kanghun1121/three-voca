import OSLog

import Dependencies

public struct LoggerClient: Sendable {
    public var debug: @Sendable (_ category: String, _ message: String) -> Void
    public var error: @Sendable (_ category: String, _ message: String) -> Void

    public init(
        debug: @escaping @Sendable (_ category: String, _ message: String) -> Void,
        error: @escaping @Sendable (_ category: String, _ message: String) -> Void
    ) {
        self.debug = debug
        self.error = error
    }
}

public extension DependencyValues {
    var loggerClient: LoggerClient {
        get { self[LoggerClient.self] }
        set { self[LoggerClient.self] = newValue }
    }
}

// MARK: - Live

extension LoggerClient: DependencyKey {
    public static let liveValue = LoggerClient(
        debug: { category, message in
            Logger(subsystem: "com.kangdev.FiveVoca", category: category).debug("\(message)")
        },
        error: { category, message in
            Logger(subsystem: "com.kangdev.FiveVoca", category: category).error("\(message)")
        }
    )
}

extension LoggerClient: TestDependencyKey {
    public static let testValue = LoggerClient(
        debug: unimplemented("\(Self.self).debug"),
        error: unimplemented("\(Self.self).error")
    )

    public static let previewValue = LoggerClient(
        debug: unimplemented("\(Self.self).debug"),
        error: unimplemented("\(Self.self).error")
    )
}
