import Dependencies
import DomainInterface
import Foundation

@Observable
@MainActor
public final class HomeViewModel {
    private(set) var state: HomeViewState?
    private(set) var isLoading: Bool = true
    private(set) var errorMessage: String?
    private(set) var expandedLevelIDs: Set<String> = []

    @ObservationIgnored @Dependency(\.homeClient) private var homeClient

    public init() {}

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let library = try await homeClient.fetchHomeOverview()
            state = library.toHomeViewState()
        } catch {
            errorMessage = "홈 정보를 불러오지 못했습니다."
        }
    }

    public func toggleLevel(id: String) {
        if expandedLevelIDs.contains(id) {
            expandedLevelIDs.remove(id)
        } else {
            expandedLevelIDs.insert(id)
        }
    }
}
