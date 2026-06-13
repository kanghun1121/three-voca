import Foundation

import Core
import DomainInterface

import Dependencies

extension WordClient: DependencyKey {
    public static let liveValue: WordClient = {
        let authSessionClient = AuthSessionClient.liveValue
        let http = HTTPClient(interceptor: TokenRefreshInterceptor(authSessionClient: authSessionClient))
        let cache = WordDetailCache()
        return WordClient(
            fetchWordDetail: { id in
                if let cached = await cache.get(id) { return cached }
                let request = GetWordDetailRequest(wordID: id)
                let dto: WordDetailResponseDTO = try await http.request(request)
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
                                GetWordDetailRequest(wordID: id)
                            ) else { return }
                            await cache.set(id, dto.toDomain())
                        }
                    }
                }
            }
        )
    }()
}
