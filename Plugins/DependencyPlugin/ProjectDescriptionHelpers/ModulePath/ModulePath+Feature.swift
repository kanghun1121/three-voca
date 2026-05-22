import ProjectDescription

public extension ModulePath {
    enum Feature: String, CaseIterable {
        case home = "Home"
        case session = "Session"

        public static let name: String = "Feature"
    }
}
