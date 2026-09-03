import Foundation

struct ClaudeChatMessage: Sendable, Equatable, Codable {
    let role: String
    let content: String
}
