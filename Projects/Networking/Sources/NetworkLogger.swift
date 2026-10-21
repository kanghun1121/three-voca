import Foundation

import Core
import Dependencies

struct NetworkLogger {
    func logRequest(_ request: URLRequest) {
        @Dependency(\.loggerClient) var loggerClient

        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "nil"
        loggerClient.debug("Network", "[\(method)] \(url)")

        guard ProcessInfo.processInfo.environment["ENABLE_NETWORK_LOG"] == "1" else { return }

        var message = "[Request] [\(method)] \(url)"

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            message += "\nHeaders: \(headers)"
        }
        if let body = request.httpBody {
            message += "\nBody:\n\(prettyJSON(body))"
        }

        print(message)
    }

    func logResponse(
        _ response: URLResponse,
        statusCode: Int,
        data: Data
    ) {
        @Dependency(\.loggerClient) var loggerClient

        let url = response.url?.absoluteString ?? "nil"
        if (200..<300).contains(statusCode) {
            loggerClient.debug("Network", "[\(statusCode)] \(url)")
        } else {
            loggerClient.error("Network", "[\(statusCode)] \(url) — \(String(data: data, encoding: .utf8) ?? "")")
        }

        guard ProcessInfo.processInfo.environment["ENABLE_NETWORK_LOG"] == "1" else { return }

        let statusEmoji = (200..<300).contains(statusCode) ? "✅" : "❌"
        var message = "\(statusEmoji) [Response] [\(statusCode)] \(url)"
        message += "\nBody:\n\(prettyJSON(data))"

        print(message)
    }

    func logError(_ error: Error, context: String) {
        @Dependency(\.loggerClient) var loggerClient

        loggerClient.error("Network", "\(context): \(error.localizedDescription)")

        guard ProcessInfo.processInfo.environment["ENABLE_NETWORK_LOG"] == "1" else { return }

        print("❌ [NetworkError] \(context): \(error.localizedDescription)")
    }
}

private extension NetworkLogger {
    func prettyJSON(_ data: Data) -> String {
        guard
            let json = try? JSONSerialization.jsonObject(with: data),
            let pretty = try? JSONSerialization.data(
                withJSONObject: json,
                options: [.prettyPrinted, .sortedKeys]
            ),
            let string = String(data: pretty, encoding: .utf8)
        else {
            return String(data: data, encoding: .utf8) ?? "(binary \(data.count) bytes)"
        }
        return string
    }
}
