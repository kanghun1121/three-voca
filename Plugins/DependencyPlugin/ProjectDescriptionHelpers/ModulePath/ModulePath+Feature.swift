import ProjectDescription

public extension ModulePath {
    enum Feature: String, CaseIterable {
        case home = "Home"
        case session = "Session"
        case vocabulary = "Vocabulary"

        public static let name = "Feature"
    }
}
