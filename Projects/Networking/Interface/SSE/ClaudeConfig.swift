import Foundation

public enum ClaudeConfig {
    public static let baseURL = URL(string: "https://api.anthropic.com")!
    public static let apiKey: String = {
        Bundle.main.object(forInfoDictionaryKey: "CLAUDE_API_KEY") as? String ?? ""
    }()
}
