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
                            guard let remoteURL = await fetchMP3URL(term: term, http: http) else { return }
                            // MP3를 임시 디렉토리에 미리 다운로드해두어
                            // 재생 버튼 탭 시 AVPlayer가 네트워크 요청 없이 즉시 재생할 수 있게 한다.
                            guard let localURL = await downloadMP3(from: remoteURL, term: term, http: http) else { return }
                            await cache.set(term, localURL)
                        }
                    }
                }
            },
            audioURL: { term in
                if let cached = await cache.get(term) { return cached }
                // prefetch가 완료되지 않은 상태에서 탭한 경우 — 직접 다운로드 후 캐싱
                guard let remoteURL = await fetchMP3URL(term: term, http: http) else { return nil }
                guard let localURL = await downloadMP3(from: remoteURL, term: term, http: http) else { return nil }
                await cache.set(term, localURL)
                return localURL
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

    // 앱 재시작 전까지 유효한 임시 디렉토리에 저장한다.
    // AVPlayer는 URLCache를 사용하지 않으므로 file:// URL을 직접 전달해야 즉시 재생된다.
    static func downloadMP3(from url: URL, term: String, http: HTTPClient) async -> URL? {
        guard let data = try? await http.requestData(DownloadMP3Request(url: url)) else { return nil }
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(term).mp3")
        try? data.write(to: fileURL)
        return fileURL
    }
}
