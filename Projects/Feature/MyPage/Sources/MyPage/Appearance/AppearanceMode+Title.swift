import DesignSystem

extension AppearanceMode {
    var title: String {
        switch self {
        case .system: "시스템 설정"
        case .light: "라이트 모드"
        case .dark: "다크 모드"
        }
    }
}
