import Core
import Dependencies
import DomainInterface
import Foundation

extension WordClient: DependencyKey {
    public static let liveValue: WordClient = {
        let http = HTTPClient()
        return WordClient(
            fetchWordDetail: { id in
                let request = GetWordDetailRequest(wordID: id)
                let dto: WordDetailResponseDTO = try await http.request(request, accessToken: nil)
                return dto.toDomain()
            }
        )
    }()
}
