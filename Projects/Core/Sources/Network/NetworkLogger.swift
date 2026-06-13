import Foundation

struct NetworkLogger {
    func logRequest(_ request: URLRequest) {
        guard ProcessInfo.processInfo.environment["ENABLE_NETWORK_LOG"] == "1" else { return }

        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "nil"
        var message = "[Request] [\(method)] \(url)"

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            message += "\nHeaders: \(headers)"
        }
        if let body = request.httpBody {
            message += "\nBody:\n\(prettyJSON(body))"
        }

        print(message)
    }

    func logResponse(_ response: URLResponse, statusCode: Int, data: Data) {
        guard ProcessInfo.processInfo.environment["ENABLE_NETWORK_LOG"] == "1" else { return }

        let url = response.url?.absoluteString ?? "nil"
        let statusEmoji = (200..<300).contains(statusCode) ? "✅" : "❌"
        var message = "\(statusEmoji) [Response] [\(statusCode)] \(url)"
        message += "\nBody:\n\(prettyJSON(data))"

        print(message)
    }

    func logError(_ error: Error, context: String) {
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
