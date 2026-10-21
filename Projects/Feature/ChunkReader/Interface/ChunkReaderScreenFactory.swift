import SwiftUI

import Dependencies

/// 다른 Feature가 ChunkReader 화면을 열 때 쓰는 진입 계약. 구현체는 FeatureChunkReader가 제공한다.
public protocol ChunkReaderScreenFactory: Sendable {
    @MainActor func makeScreen(route: ChunkReaderRoute) -> AnyView
}

/// 구현체가 주입되지 않은 환경(Example, 프리뷰, 테스트)에서 쓰는 빈 화면.
public struct PlaceholderChunkReaderScreenFactory: ChunkReaderScreenFactory {
    public init() {}

    @MainActor
    public func makeScreen(route: ChunkReaderRoute) -> AnyView {
        AnyView(EmptyView())
    }
}

public enum ChunkReaderScreenFactoryKey: TestDependencyKey {
    public static let testValue: any ChunkReaderScreenFactory = PlaceholderChunkReaderScreenFactory()
    public static let previewValue: any ChunkReaderScreenFactory = PlaceholderChunkReaderScreenFactory()
}

public extension DependencyValues {
    var chunkReaderScreenFactory: any ChunkReaderScreenFactory {
        get { self[ChunkReaderScreenFactoryKey.self] }
        set { self[ChunkReaderScreenFactoryKey.self] = newValue }
    }
}
