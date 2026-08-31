import Foundation

struct ClaudeMessagesRequestBody: Encodable {
    let model: String
    let maxTokens: Int
    let stream = true
    let messages: [ClaudeChatMessage]

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case stream
        case messages
    }
}
