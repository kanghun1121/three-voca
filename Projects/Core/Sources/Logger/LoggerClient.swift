import OSLog

import Dependencies
import DependenciesMacros

@DependencyClient
public struct LoggerClient: Sendable {
    public var debug: @Sendable (_ category: String, _ message: String) -> Void
    public var error: @Sendable (_ category: String, _ message: String) -> Void
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

extension LoggerClient: UnimplementedTestDependencyKey {}
