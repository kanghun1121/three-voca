import Foundation

import DomainInterface

/// ChunkReader 화면 진입에 필요한 값. 호출 Feature는 이 값만 알고 ViewModel은 알지 못한다.
public struct ChunkReaderRoute {
    public let chunks: [WordDetail.Example.Chunk]
    public let wordAnnotations: [WordDetail.Example.WordAnnotation]

    public init(
        chunks: [WordDetail.Example.Chunk],
        wordAnnotations: [WordDetail.Example.WordAnnotation]
    ) {
        self.chunks = chunks
        self.wordAnnotations = wordAnnotations
    }
}
