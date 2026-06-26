import AVFoundation

import Dependencies

struct SoundClient {
    var playCorrect: @Sendable () -> Void
    var playWrong: @Sendable () -> Void
}

extension SoundClient: DependencyKey {
    static let liveValue = SoundClient(
        playCorrect: { SoundPlayer.shared.play(resource: "correct_a", extension: "wav") },
        playWrong: { SoundPlayer.shared.play(resource: "wrong_b", extension: "wav") }
    )

    static let testValue = SoundClient(
        playCorrect: unimplemented("\(Self.self).playCorrect"),
        playWrong: unimplemented("\(Self.self).playWrong")
    )

    static let previewValue = SoundClient(
        playCorrect: {},
        playWrong: {}
    )
}

extension DependencyValues {
    var soundClient: SoundClient {
        get { self[SoundClient.self] }
        set { self[SoundClient.self] = newValue }
    }
}

// AVAudioPlayer는 재생 중 참조가 유지되어야 하므로 싱글턴으로 관리한다.
private final class SoundPlayer: @unchecked Sendable {
    static let shared = SoundPlayer()
    private var player: AVAudioPlayer?

    func play(resource: String, extension ext: String) {
        guard let url = Bundle.module.url(forResource: resource, withExtension: ext) else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}
