import SwiftUI

import DomainInterface
import FeatureHome

import Dependencies

@main
struct HomeExampleApp: App {
    var body: some Scene {
        WindowGroup {
            HomeCaseListView()
        }
    }
}

/// Home 화면의 확인 시나리오.
private enum HomeCase: String, CaseIterable, Identifiable {
    case emptyPath = "기록 없음"
    case happyPath = "여러 기록"

    var id: Self { self }

    @MainActor
    func makeViewModel() -> HomeViewModel {
        withDependencies {
            switch self {
            case .emptyPath: $0.learningHistoryRepository = .emptyPath
            case .happyPath: $0.learningHistoryRepository = .happyPath
            }
        } operation: {
            HomeViewModel()
        }
    }
}

/// 시나리오를 고르는 진입 화면. 항목을 누르면 해당 시나리오로 Home 화면이 열린다.
private struct HomeCaseListView: View {
    var body: some View {
        NavigationStack {
            List(HomeCase.allCases) { homeCase in
                NavigationLink(homeCase.rawValue) {
                    HomeView(viewModel: homeCase.makeViewModel())
                        .navigationTitle(homeCase.rawValue)
                        .navigationBarTitleDisplayMode(.inline)
                }
            }
            .navigationTitle("Home 시나리오")
        }
    }
}
