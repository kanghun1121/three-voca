import AVFoundation
import Dependencies
import DomainInterface
import Foundation

extension AudioPlayerClient: DependencyKey {
    public static let liveValue: AudioPlayerClient = {
        let player = AVPlayer()
        return AudioPlayerClient(
            play: { url in
                let item = AVPlayerItem(url: url)
                player.replaceCurrentItem(with: item)
                player.play()
            }
        )
    }()
}
