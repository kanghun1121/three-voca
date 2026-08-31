import Foundation

import NetworkingInterface

/// requiresAuthentication은 이 요청이 HTTPClient의 인터셉터 파이프라인을 타지 않아
/// (SSEClient가 session.bytes(for:)로 직접 요청하므로) 실제로는 읽히지 않는다 — 고정 x-api-key
/// 헤더만 쓴다는 의도를 명시하기 위해 false로 남겨둔다.
struct ClaudeMessagesRequest: Requestable {
    let model: String
    let maxTokens: Int
    let messages: [ClaudeChatMessage]

    var baseURL: URL { ClaudeConfig.baseURL }
    var path: String { "v1/messages" }
    var method: HTTPMethod { .post }
    var bodyParameters: HTTPBody { .json(ClaudeMessagesRequestBody(model: model, maxTokens: maxTokens, messages: messages)) }
    var headers: [String: String] {
        [
            "x-api-key": ClaudeConfig.apiKey,
            "anthropic-version": "2023-06-01"
        ]
    }
    var requiresAuthentication: Bool { false }
}
