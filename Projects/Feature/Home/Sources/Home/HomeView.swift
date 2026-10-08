import SwiftUI

import DesignSystem
import FeatureLessonInterface

import Dependencies
import SwiftUINavigation

public struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @Dependency(\.lessonScreenFactory) private var lessonScreenFactory

    public init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            HomeContentView(viewModel: viewModel)
                .task { await viewModel.onAppear() }
                .navigationDestination(item: $viewModel.destination.lesson) { lessonID in
                    lessonScreenFactory.makeLessonDetailScreen(lessonID: lessonID.wrappedValue)
                }
                .navigationDestination(isPresented: Binding($viewModel.destination.learningLibrary)) {
                    lessonScreenFactory.makeLearningLibraryScreen()
                }
        }
        .tint(DesignSystemColor.Foreground.strong)
        .toolbar(viewModel.destination != nil ? .hidden : .visible, for: .tabBar)
    }
}

#Preview("홈") {
    HomeView(viewModel: HomeViewModel())
}
