import Dependencies
import DomainInterface
import Foundation

extension AudioClient: DependencyKey {
    public static let liveValue: AudioClient = {
        let session = URLSession.shared
        return AudioClient(
            prefetchAudio: { terms in
                guard let apiKey = Bundle.main.infoDictionary?["MW_DICTIONARY_API_KEY"] as? String,
                      !apiKey.isEmpty else { return }

                await withTaskGroup(of: Void.self) { group in
                    for term in terms {
                        group.addTask {
                            guard let mp3URL = await fetchAudioURL(term: term, apiKey: apiKey) else { return }
                            _ = try? await session.data(from: mp3URL)
                        }
                    }
                }
            }
        )
    }()
}

private func fetchAudioURL(term: String, apiKey: String) async -> URL? {
    guard let requestURL = URL(string: "https://www.dictionaryapi.com/api/v3/references/collegiate/json/\(term)?key=\(apiKey)") else { return nil }

    guard let (data, _) = try? await URLSession.shared.data(from: requestURL),
          let entries = try? JSONDecoder().decode([MWEntry].self, from: data),
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

// MARK: - Decodable Models

private struct MWEntry: Decodable {
    let hwi: HWI?

    struct HWI: Decodable {
        let prs: [Pronunciation]?

        struct Pronunciation: Decodable {
            let sound: Sound?

            struct Sound: Decodable {
                let audio: String?
            }
        }
    }
}
