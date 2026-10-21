import Foundation

import DomainInterface

extension LearningLibraryRepository {
    /// 레벨별 진행도가 제각각인 라이브러리: 0/42(시작 전), 15/39(진행 중), 99/99(전부 완료), 48/64(절반 이상).
    /// 완료 세션은 앞에서부터 연속으로 채우고, 학습 시각과 정확도는 인덱스로 결정해 매번 같은 모양이 나온다.
    static let happyPath: LearningLibraryRepository = {
        let now = Date.now
        // (id, 레벨 번호, 이름, 난이도, 전체 세션 수, 완료 세션 수)
        let specs: [(id: String, level: Int, name: String, difficulty: String, total: Int, completed: Int)] = [
            ("level_1", 1, "입문", "A1", 42, 0),
            ("level_2", 2, "기초", "A2", 39, 15),
            ("level_3", 3, "활용", "B1", 99, 99),
            ("level_4", 4, "확장", "B2", 64, 48),
        ]
        var nextLessonID = 1
        let levels = specs.map { spec in
            let lessons = (1...spec.total).map { number -> LessonProgress in
                defer { nextLessonID += 1 }
                let isCompleted = number <= spec.completed
                return LessonProgress(
                    id: "\(nextLessonID)",
                    lessonNumber: number,
                    totalWords: 20,
                    status: isCompleted ? .completed : .notStarted,
                    lastStudiedAt: isCompleted
                        ? now.addingTimeInterval(-Double(spec.completed - number + 1) * 3600 * 6)
                        : nil,
                    accuracy: isCompleted ? 0.6 + Double(number % 5) * 0.1 : nil,
                    wordsCompleted: isCompleted ? 20 : 0
                )
            }
            return LevelSummary(
                id: spec.id,
                level: spec.level,
                name: spec.name,
                difficulty: spec.difficulty,
                totalLessons: spec.total,
                completedLessons: spec.completed,
                lessons: lessons
            )
        }
        let library = LearningLibrary(levels: levels)
        return LearningLibraryRepository(
            stream: { AsyncStream { $0.yield(library); $0.finish() } },
            refresh: {}
        )
    }()
}
