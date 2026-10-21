import Foundation

import DomainInterface

import Dependencies

extension LearningLibraryRepository: DependencyKey {
    public static let liveValue: LearningLibraryRepository = {
        @Dependency(\.learningLibraryStore) var store
        @Dependency(\.levelLocalDataSource) var levelDataSource
        @Dependency(\.lessonLocalDataSource) var lessonDataSource
        @Dependency(\.learningHistoryLocalDataSource) var historyDataSource
        @Dependency(\.uuid) var uuid

        @Sendable
        func refreshLearningLibrary() async throws {
            var summaries: [LevelSummary] = []
            for entity in try await levelDataSource.allLevels() {
                let lessons = try await lessonDataSource.lessons(entity.id)
                summaries.append(entity.toStaticSummary(lessons: lessons))
            }

            let completions = try await historyDataSource.allCompletions()
            let completionByLessonID = completions.reduce(into: [String: LearningHistoryEntity]()) { result, entity in
                result[String(entity.lessonID)] = entity
            }

            let levels = summaries.map { level -> LevelSummary in
                let lessons = level.lessons.map { lesson -> LessonProgress in
                    guard let completion = completionByLessonID[lesson.id] else { return lesson }
                    return LessonProgress(
                        id: lesson.id,
                        lessonNumber: lesson.lessonNumber,
                        totalWords: lesson.totalWords,
                        status: .completed,
                        lastStudiedAt: completion.lastStudiedAt,
                        accuracy: nil,
                        wordsCompleted: lesson.totalWords
                    )
                }
                return LevelSummary(
                    id: level.id,
                    level: level.level,
                    name: level.name,
                    difficulty: level.difficulty,
                    totalLessons: level.totalLessons,
                    completedLessons: lessons.filter { $0.status == .completed }.count,
                    lessons: lessons
                )
            }

            await store.set(LearningLibrary(levels: levels))
        }

        return LearningLibraryRepository(
            stream: {
                AsyncStream { continuation in
                    Task {
                        let id = uuid()
                        await store.register(id: id, continuation: continuation)
                        try? await refreshLearningLibrary()
                    }
                }
            },
            refresh: {
                try await refreshLearningLibrary()
            }
        )
    }()
}
