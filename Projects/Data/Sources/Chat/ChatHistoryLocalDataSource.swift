import Foundation
import SwiftData

import Dependencies

struct ChatHistoryLocalDataSource: Sendable {
    var messages: @Sendable (_ wordID: String) async throws -> [ChatMessagePayload]
    /// 해당 wordID의 행이 있으면 메시지 배열을 통째로 교체하고, 없으면 새로 만든다. fetch→분기→save를
    /// 하나의 액터 격리 안에서 수행해 원자성을 보장한다(`LearningHistoryLocalDataSource.recordCompletion`과
    /// 동일한 패턴).
    var save: @Sendable (_ wordID: String, _ messages: [ChatMessagePayload]) async throws -> Void
}

extension ChatHistoryLocalDataSource: DependencyKey {
    static let liveValue = ChatHistoryLocalDataSource(
        messages: { wordID in
            @Dependency(\.localDatabaseContext) var context
            return try await context.fetch(FetchDescriptor<ChatHistoryEntity>(
                predicate: #Predicate { $0.wordID == wordID }
            )).first?.messages ?? []
        },
        save: { wordID, messages in
            @Dependency(\.localDatabaseContext) var context
            try await context.withContext { modelContext in
                let existing = try modelContext.fetch(FetchDescriptor<ChatHistoryEntity>(
                    predicate: #Predicate { $0.wordID == wordID }
                )).first
                if let existing {
                    existing.messages = messages
                } else {
                    modelContext.insert(ChatHistoryEntity(wordID: wordID, messages: messages))
                }
                try modelContext.save()
            }
        }
    )
}


extension DependencyValues {
    var chatHistoryLocalDataSource: ChatHistoryLocalDataSource {
        get { self[ChatHistoryLocalDataSource.self] }
        set { self[ChatHistoryLocalDataSource.self] = newValue }
    }
}
