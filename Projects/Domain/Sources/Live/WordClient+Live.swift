import Core
import Dependencies
import DomainInterface
import Foundation

extension WordClient: DependencyKey {
    public static let liveValue: WordClient = {
        let http = HTTPClient()
        let cache = WordDetailCache()
        return WordClient(
            fetchWordDetail: { id in
                if let cached = await cache.get(id) { return cached }
                let request = GetWordDetailRequest(wordID: id)
                let dto: WordDetailResponseDTO = try await http.request(request, accessToken: nil)
                let detail = dto.toDomain()
                await cache.set(id, detail)
                return detail
            },
            prefetchWordDetails: { ids in
                await withTaskGroup(of: Void.self) { group in
                    for id in ids {
                        group.addTask {
                            guard await cache.get(id) == nil else { return }
                            guard let dto: WordDetailResponseDTO = try? await http.request(
                                GetWordDetailRequest(wordID: id),
                                accessToken: nil
                            ) else { return }
                            await cache.set(id, dto.toDomain())
                        }
                    }
                }
            }
        )
    }()
}
