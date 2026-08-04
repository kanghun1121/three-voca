import AVFoundation
import Foundation

import DomainInterface

import Dependencies

extension AudioPlayerClient: DependencyKey {
    public static let liveValue: AudioPlayerClient = {
        let player = AVPlayer()
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(
            .playback,
            mode: .default,
            options: [.mixWithOthers]
        )
        try? session.setActive(true)
        return AudioPlayerClient(
            play: { url in
                let item = AVPlayerItem(url: url)
                player.replaceCurrentItem(with: item)
                player.play()
            },
            stop: {
                player.replaceCurrentItem(with: nil)
            }
        )
    }()
}
