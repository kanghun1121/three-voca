import Foundation

import Dependencies

public struct AudioClient: Sendable {
    public var prefetchAudio: @Sendable (_ terms: [String]) async -> Void
    public var audioURL: @Sendable (_ term: String) async -> URL?

    public init(
        prefetchAudio: @escaping @Sendable (_ terms: [String]) async -> Void,
        audioURL: @escaping @Sendable (_ term: String) async -> URL?
    ) {
        self.prefetchAudio = prefetchAudio
        self.audioURL = audioURL
    }
}

extension AudioClient: TestDependencyKey {
    public static let testValue = AudioClient(
        prefetchAudio: unimplemented("\(Self.self).prefetchAudio", placeholder: ()),
        audioURL: unimplemented("\(Self.self).audioURL", placeholder: nil)
    )

    public static let previewValue = AudioClient(
        prefetchAudio: { _ in },
        audioURL: { _ in nil }
    )
}

public extension DependencyValues {
    var audioClient: AudioClient {
        get { self[AudioClient.self] }
        set { self[AudioClient.self] = newValue }
    }
}
