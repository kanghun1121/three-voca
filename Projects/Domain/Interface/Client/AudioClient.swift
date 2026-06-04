import Dependencies
import Foundation

public struct AudioClient: Sendable {
    public var prefetchAudio: @Sendable (_ terms: [String]) async -> Void

    public init(prefetchAudio: @escaping @Sendable (_ terms: [String]) async -> Void) {
        self.prefetchAudio = prefetchAudio
    }
}

extension AudioClient: TestDependencyKey {
    public static let testValue = AudioClient(
        prefetchAudio: unimplemented("\(Self.self).prefetchAudio", placeholder: ())
    )

    public static let previewValue = AudioClient(
        prefetchAudio: { _ in }
    )
}

public extension DependencyValues {
    var audioClient: AudioClient {
        get { self[AudioClient.self] }
        set { self[AudioClient.self] = newValue }
    }
}
