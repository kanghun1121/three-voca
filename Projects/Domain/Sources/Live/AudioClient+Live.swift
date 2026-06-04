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
                            guard await cache.get(term) == nil else {
                                print("[AudioCache] HIT (prefetch) — \(term)")
                                return
                            }
                            guard let mp3URL = await fetchMP3URL(term: term, http: http) else {
                                print("[AudioCache] MISS (prefetch, no URL) — \(term)")
                                return
                            }
                            await cache.set(term, mp3URL)
                            print("[AudioCache] STORED — \(term): \(mp3URL)")
                        }
                    }
                }
            },
            audioURL: { term in
                if let cached = await cache.get(term) {
                    print("[AudioCache] HIT — \(term): \(cached)")
                    return cached
                }
                guard let mp3URL = await fetchMP3URL(term: term, http: http) else {
                    print("[AudioCache] MISS (no URL) — \(term)")
                    return nil
                }
                await cache.set(term, mp3URL)
                print("[AudioCache] STORED — \(term): \(mp3URL)")
                return mp3URL
            }
        )
    }()
}

private extension AudioClient {
    static func fetchMP3URL(term: String, http: HTTPClient) async -> URL? {
        guard let entries: [MWEntryResponseDTO] = try? await http.request(GetMWAudioRequest(term: term)),
              let audio = entries.first?.hwi?.prs?.first?.sound?.audio,
              !audio.isEmpty else { return nil }

        guard let subdir = audio.first.map(String.init) else { return nil }
        return URL(string: "https://media.merriam-webster.com/audio/prons/en/us/mp3/\(subdir)/\(audio).mp3")
    }
}
