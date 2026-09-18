import Foundation
import SwiftData

import Core

import Dependencies
import DependenciesMacros

@DependencyClient
struct LearningHistoryLocalDataSource: Sendable {
    var allCompletions: @Sendable () async throws -> [LearningHistoryEntity]
    var completion: @Sendable (_ lessonID: Int) async throws -> LearningHistoryEntity?
    /// 이미 완료 기록이 있으면 studyCount 증가 + lastStudiedAt 갱신(firstCompletedAt은 보존),
    /// 없으면 새로 생성한다. fetch→분기→save를 하나의 액터 격리 안에서 수행해 원자성을 보장한다.
    var recordCompletion: @Sendable (_ lessonID: Int, _ date: Date) async throws -> Void
}

extension LearningHistoryLocalDataSource: DependencyKey {
    static let liveValue = LearningHistoryLocalDataSource(
        allCompletions: {
            @Dependency(\.localDatabaseContext) var context
            return try await context.fetch(FetchDescriptor<LearningHistoryEntity>())
        },
        completion: { lessonID in
            @Dependency(\.localDatabaseContext) var context
            return try await context.fetch(FetchDescriptor<LearningHistoryEntity>(
                predicate: #Predicate { $0.lessonID == lessonID }
            )).first
        },
        recordCompletion: { lessonID, date in
            @Dependency(\.localDatabaseContext) var context
            try await context.withContext { modelContext in
                let existing = try modelContext.fetch(FetchDescriptor<LearningHistoryEntity>(
                    predicate: #Predicate { $0.lessonID == lessonID }
                )).first
                if let existing {
                    existing.lastStudiedAt = date
                    existing.studyCount += 1
                } else {
                    modelContext.insert(LearningHistoryEntity(lessonID: lessonID, firstCompletedAt: date, lastStudiedAt: date, studyCount: 1))
                }
                try modelContext.save()
            }
        }
    )
}

extension LearningHistoryLocalDataSource: UnimplementedTestDependencyKey {}


extension DependencyValues {
    var learningHistoryLocalDataSource: LearningHistoryLocalDataSource {
        get { self[LearningHistoryLocalDataSource.self] }
        set { self[LearningHistoryLocalDataSource.self] = newValue }
    }
}
