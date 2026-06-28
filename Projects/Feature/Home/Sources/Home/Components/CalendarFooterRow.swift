import SwiftUI

import DesignSystem

struct CalendarFooterRow: View {
    let streakDays: Int
    let isAtCurrentMonth: Bool

    var body: some View {
        HStack(spacing: 0) {
            if streakDays > 0 && isAtCurrentMonth {
                CalendarStreakLabel(streakDays: streakDays)
            }
            Spacer()
        }
    }
}
