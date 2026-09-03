import Foundation

import DomainInterface

import Dependencies

extension SendChatMessageUseCase: DependencyKey {
    public static let liveValue = SendChatMessageUseCase(
        execute: { message in
            @Dependency(\.chatRepository) var chatRepository
            return chatRepository.streamMessage(message)
        }
    )
}
