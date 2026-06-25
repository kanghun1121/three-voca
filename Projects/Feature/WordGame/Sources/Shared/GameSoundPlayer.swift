import AVFoundation

@MainActor
final class GameSoundPlayer {
    private var player: AVAudioPlayer?

    func playCorrect() {
        play(resource: "correct_a", extension: "wav")
    }

    func playWrong() {
        play(resource: "wrong_b", extension: "wav")
    }

    private func play(resource: String, extension ext: String) {
        guard let url = Bundle.module.url(forResource: resource, withExtension: ext) else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}
