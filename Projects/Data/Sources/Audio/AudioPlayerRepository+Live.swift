import AVFoundation
import Foundation

import DomainInterface

import Dependencies

extension AudioPlayerRepository: DependencyKey {
    public static let liveValue: AudioPlayerRepository = {
        let player = AVPlayer()
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(
            .playback,
            mode: .default,
            options: [.mixWithOthers]
        )
        try? session.setActive(true)
        return AudioPlayerRepository(
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
