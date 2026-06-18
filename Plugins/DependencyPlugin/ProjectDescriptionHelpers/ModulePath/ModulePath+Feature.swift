import ProjectDescription

public extension ModulePath {
    enum Feature: String, CaseIterable {
        case home = "Home"
        case login = "Login"
        case session = "Session"
        case vocabulary = "Vocabulary"
        case wordGame = "WordGame"
        case myPage = "MyPage"

        public static let name = "Feature"
    }
}
