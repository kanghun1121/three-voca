import SwiftUI

import DomainInterface

struct SessionListSection: View {
    let lessons: [LessonProgress]
    let level: Int
    let onSessionTapped: (String) -> Void

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(lessons) { lesson in
                SessionRow(lesson: lesson, level: level) {
                    onSessionTapped(lesson.id)
                }
            }
        }
    }
}
