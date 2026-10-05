import XCTest

import DomainInterface

import Dependencies

@testable import FeatureChunkReader

@MainActor
final class ChunkReaderTests: XCTestCase {
    func test_첫_청크를_탭하면_텍스트로_오디오_URL을_요청하고_재생한다() async {
        let expectedURL = URL(string: "https://example.com/the-teacher.mp3")!
        let played = expectation(description: "선택한 청크 오디오 재생")
        let viewModel = withDependencies {
            $0.audioRepository.chunkAudioURL = { text in
                XCTAssertEqual(text, "the teacher")
                return expectedURL
            }
            $0.audioPlayerRepository.play = { url in
                XCTAssertEqual(url, expectedURL)
                played.fulfill()
            }
            $0.audioPlayerRepository.stop = {}
        } operation: {
            ChunkReaderViewModel(
                chunks: [.init(text: "the teacher", meaning: "그 선생님")],
                wordAnnotations: []
            )
        }

        XCTAssertEqual(viewModel.selectedChunkID, 0)
        viewModel.didTapChunk(id: 0)
        await fulfillment(of: [played], timeout: 2)
        XCTAssertEqual(viewModel.selectedChunkID, 0)
    }
}
