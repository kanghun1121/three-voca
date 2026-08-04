import Foundation

import Dependencies

public struct AudioPlayerClient: Sendable {
    public var play: @Sendable (_ url: URL) async -> Void
    public var stop: @Sendable () -> Void

    public init(
        play: @escaping @Sendable (_ url: URL) async -> Void,
        stop: @escaping @Sendable () -> Void
    ) {
        self.play = play
        self.stop = stop
    }
}

extension AudioPlayerClient: TestDependencyKey {
    public static let testValue = AudioPlayerClient(
        play: unimplemented("\(Self.self).play", placeholder: ()),
        stop: unimplemented("\(Self.self).stop")
    )

    public static let previewValue = AudioPlayerClient(
        play: { _ in },
        stop: {}
    )
}

public extension DependencyValues {
    var audioPlayerClient: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}
