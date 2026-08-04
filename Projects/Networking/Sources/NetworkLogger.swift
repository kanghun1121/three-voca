import Foundation
import OSLog

private let logger = Logger(subsystem: "com.kangdev.FiveVoca", category: "Network")

struct NetworkLogger {
    func logRequest(_ request: URLRequest) {
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "nil"
        logger.debug("[\(method)] \(url)")

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
        let url = response.url?.absoluteString ?? "nil"
        if (200..<300).contains(statusCode) {
            logger.debug("[\(statusCode)] \(url)")
        } else {
            logger.error("[\(statusCode)] \(url) — \(String(data: data, encoding: .utf8) ?? "")")
        }

        guard ProcessInfo.processInfo.environment["ENABLE_NETWORK_LOG"] == "1" else { return }

        let statusEmoji = (200..<300).contains(statusCode) ? "✅" : "❌"
        var message = "\(statusEmoji) [Response] [\(statusCode)] \(url)"
        message += "\nBody:\n\(prettyJSON(data))"

        print(message)
    }

    func logError(_ error: Error, context: String) {
        logger.error("\(context): \(error.localizedDescription)")

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
