import SwiftUI

import FeatureChunkReaderInterface

import Dependencies

public struct LiveChunkReaderScreenFactory: ChunkReaderScreenFactory {
    public init() {}

    @MainActor
    public func makeScreen(route: ChunkReaderRoute) -> AnyView {
        AnyView(ChunkReaderScreen(route: route))
    }
}

/// ViewModel 수명을 화면이 소유한다. 부모 body가 다시 평가돼도 상태가 초기화되지 않는다.
private struct ChunkReaderScreen: View {
    @State private var viewModel: ChunkReaderViewModel

    init(route: ChunkReaderRoute) {
        _viewModel = State(initialValue: ChunkReaderViewModel(
            chunks: route.chunks,
            wordAnnotations: route.wordAnnotations
        ))
    }

    var body: some View {
        ChunkReaderView(viewModel: viewModel)
    }
}

extension ChunkReaderScreenFactoryKey: DependencyKey {
    public static let liveValue: any ChunkReaderScreenFactory = LiveChunkReaderScreenFactory()
}
