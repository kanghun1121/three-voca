import Foundation

import DomainInterface

extension LearningHistoryRepository {
    /// 학습 기록이 하나도 없는 신규 사용자.
    static let emptyPath = LearningHistoryRepository(
        stream: { _ in AsyncStream { $0.finish() } },
        streamAllCompletions: { AsyncStream { $0.yield([]); $0.finish() } },
        complete: { _ in }
    )

    /// 지난달 ~ 이번 달(오늘까지)을 하루 0·1·2·3회 학습으로 채운 기록.
    /// 일(day) 번호를 4로 나눈 나머지를 학습 횟수로 써서 0~3회가 고르게 섞인다.
    static let happyPath: LearningHistoryRepository = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        var records: [LessonCompletionRecord] = []
        for monthOffset in [-1, 0] {
            guard let month = calendar.date(byAdding: .month, value: monthOffset, to: today),
                  let monthStart = calendar.dateInterval(of: .month, for: month)?.start,
                  let days = calendar.range(of: .day, in: .month, for: month)
            else { continue }
            for day in days {
                guard let dayStart = calendar.date(byAdding: .day, value: day - 1, to: monthStart),
                      dayStart <= today
                else { continue }
                for index in 0..<(day % 4) {
                    guard let studiedAt = calendar.date(byAdding: .hour, value: 9 + index * 4, to: dayStart)
                    else { continue }
                    records.append(LessonCompletionRecord(
                        lessonID: "\(calendar.component(.month, from: dayStart))-\(day)-\(index)",
                        levelName: "Level \(index + 1)",
                        lessonNumber: day,
                        totalWords: 10 + index * 5,
                        lastStudiedAt: studiedAt
                    ))
                }
            }
        }
        let mockRecords = records
        return LearningHistoryRepository(
            stream: { _ in AsyncStream { $0.finish() } },
            streamAllCompletions: { AsyncStream { $0.yield(mockRecords); $0.finish() } },
            complete: { _ in }
        )
    }()
}
