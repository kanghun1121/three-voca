import Foundation

enum ClaudeMessageStreamResponse: Sendable, Equatable {
    case textDelta(String)
    case messageStop
}
