import SwiftUI

enum HomeColors {
    // MARK: - 단계별 아이콘 컬러
    static let level1 = Color(red: 0/255, green: 102/255, blue: 255/255)   // #0066FF
    static let level2 = Color(red: 91/255, green: 141/255, blue: 239/255)  // #5B8DEF
    static let level3 = Color(red: 142/255, green: 114/255, blue: 232/255) // #8E72E8
    static let level4 = Color(red: 232/255, green: 118/255, blue: 60/255)  // #E8763C
    static let level5 = Color(red: 17/255, green: 163/255, blue: 107/255)  // #11A36B

    // MARK: - 월간 캘린더 학습 강도
    static let calendarLight = Color(red: 154/255, green: 194/255, blue: 252/255) // #9AC2FC
    static let calendarMid   = Color(red: 88/255, green: 150/255, blue: 248/255)  // #5896F8

    // MARK: - 활성 카드
    static let activeBorder = Color(red: 187/255, green: 213/255, blue: 252/255) // #BBD5FC

    // MARK: - 스트릭
    static let streakOrange = Color(red: 232/255, green: 89/255, blue: 12/255)   // #E8590C
    static let streakBg     = Color(red: 255/255, green: 241/255, blue: 232/255) // #FFF1E8

    static func levelColor(_ level: Int) -> Color {
        switch level {
        case 1: level1
        case 2: level2
        case 3: level3
        case 4: level4
        case 5: level5
        default: level1
        }
    }
}

extension Color {
    static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }
}
