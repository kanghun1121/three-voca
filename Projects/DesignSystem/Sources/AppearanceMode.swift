import SwiftUI

/// 앱 다크 모드 설정. 값은 `@AppStorage(AppearanceMode.storageKey)`로 저장한다.
public enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    public static let storageKey = "appearanceMode"

    public var id: String { rawValue }

    /// `preferredColorScheme`에 넘길 값. `nil`이면 시스템 설정을 따른다.
    public var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
