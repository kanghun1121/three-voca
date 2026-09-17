import SwiftUI

import DesignSystem
import DomainInterface

struct SessionListSection: View {
    let lessons: [LessonProgress]
    let level: Int
    let onSessionTapped: (String) -> Void

    var body: some View {
        let rows = Array(zip(lessons, lessons.sessionStatuses))
        LazyVStack(spacing: 0) {
            ForEach(rows, id: \.0.id) { lesson, status in
                SessionRow(lesson: lesson, status: status, level: level) {
                    onSessionTapped(lesson.id)
                }
                if lesson.id != lessons.last?.id {
                    Rectangle()
                        .fill(DesignSystemAsset.hairline.swiftUIColor)
                        .frame(height: 1)
                }
            }
        }
    }
}
