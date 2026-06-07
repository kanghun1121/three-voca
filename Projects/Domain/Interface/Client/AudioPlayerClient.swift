import Foundation

import Dependencies

public struct AudioPlayerClient: Sendable {
    public var play: @Sendable (_ url: URL) async -> Void

    public init(play: @escaping @Sendable (_ url: URL) async -> Void) {
        self.play = play
    }
}

extension AudioPlayerClient: TestDependencyKey {
    public static let testValue = AudioPlayerClient(
        play: unimplemented("\(Self.self).play", placeholder: ())
    )

    public static let previewValue = AudioPlayerClient(
        play: { _ in }
    )
}

public extension DependencyValues {
    var audioPlayerClient: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}
