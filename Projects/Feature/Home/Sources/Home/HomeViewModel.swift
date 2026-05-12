import Foundation

import FeatureHomeInterface

@Observable
@MainActor
public final class HomeViewModel {
    private(set) var state: HomeViewState?
    private(set) var isLoading: Bool = true
    private(set) var errorMessage: String?
    private(set) var expandedLevelIDs: Set<String> = []

    private let repository: HomeRepository

    public init(repository: HomeRepository) {
        self.repository = repository
    }

    public func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let library = try await repository.fetchVocabularyLibrary()
            // TODO: 실제 streak 데이터 연동
            state = library.toHomeViewState(streakDays: 7)
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
