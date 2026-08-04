import Foundation

import DomainInterface

import Dependencies

extension AudioClient: DependencyKey {
    public static let liveValue: AudioClient = {
        let cache = AudioCache()
        return AudioClient(
            prefetchAudio: { words in
                await withTaskGroup(of: Void.self) { group in
                    for (term, audioUrlString) in words {
                        group.addTask {
                            guard await cache.fetch(term) == nil else { return }
                            guard let remoteURL = URL(string: audioUrlString) else { return }
                            // MP3를 임시 디렉토리에 미리 다운로드해두어
                            // 재생 버튼 탭 시 AVPlayer가 네트워크 요청 없이 즉시 재생할 수 있게 한다.
                            guard let localURL = await downloadMP3(from: remoteURL, term: term) else { return }
                            await cache.set(term, localURL)
                        }
                    }
                }
            },
            audioURL: { term in
                await cache.fetch(term)
            }
        )
    }()
}

private extension AudioClient {
    // 앱 재시작 전까지 유효한 임시 디렉토리에 저장한다.
    // AVPlayer는 URLCache를 사용하지 않으므로 file:// URL을 직접 전달해야 즉시 재생된다.
    static func downloadMP3(from url: URL, term: String) async -> URL? {
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
        let fileURL = URL.temporaryDirectory
            .appending(path: "\(term).mp3")
        try? data.write(to: fileURL, options: .atomic)
        return fileURL
    }
}
