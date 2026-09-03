import ProjectDescription

public extension ModulePath {
    enum Feature: String, CaseIterable {
        case analysis = "Analysis"
        case chatBot = "ChatBot"
        case home = "Home"
        case login = "Login"
        case session = "Session"
        case vocabulary = "Vocabulary"
        case wordGame = "WordGame"
        case myPage = "MyPage"

        public static let name = "Feature"
    }
}
