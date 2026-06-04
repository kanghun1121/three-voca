import Core
import Dependencies
import DomainInterface
import Foundation

extension AudioClient: DependencyKey {
    public static let liveValue: AudioClient = {
        let http = HTTPClient()
        let cache = AudioCache()
        return AudioClient(
            prefetchAudio: { terms in
                await withTaskGroup(of: Void.self) { group in
                    for term in terms {
                        group.addTask {
                            guard await cache.get(term) == nil else { return }
                            guard let mp3URL = await fetchMP3URL(term: term, http: http) else { return }
                            await cache.set(term, mp3URL)
                            _ = try? await URLSession.shared.data(from: mp3URL)
                        }
                    }
                }
            },
            audioURL: { term in
                if let cached = await cache.get(term) { return cached }
                guard let mp3URL = await fetchMP3URL(term: term, http: http) else { return nil }
                await cache.set(term, mp3URL)
                return mp3URL
            }
        )
    }()
}

private func fetchMP3URL(term: String, http: HTTPClient) async -> URL? {
    guard let entries: [MWEntryResponseDTO] = try? await http.request(GetMWAudioRequest(term: term)),
          let audio = entries.first?.hwi?.prs?.first?.sound?.audio,
          !audio.isEmpty else { return nil }

    let subdir = audioSubdir(audio)
    return URL(string: "https://media.merriam-webster.com/audio/prons/en/us/mp3/\(subdir)/\(audio).mp3")
}

private func audioSubdir(_ audio: String) -> String {
    if audio.hasPrefix("bix") { return "bix" }
    if audio.hasPrefix("gg") { return "gg" }
    if let first = audio.first, first.isNumber || first.isPunctuation { return "number" }
    return String(audio.prefix(1))
}
