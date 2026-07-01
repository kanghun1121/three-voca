import SwiftUI

import DomainInterface
import FeatureAnalysis

@main
struct AnalysisExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ChunkReaderView(viewModel: ChunkReaderViewModel(chunks: .fixtureChunks, words: .fixtureWords))
            }
        }
    }
}

private extension Array where Element == WordDetail.Example.Chunk {
    static let fixtureChunks: Self = [
        WordDetail.Example.Chunk(text: "She is afraid", meaning: "그녀는 두려워한다"),
        WordDetail.Example.Chunk(text: "of flying", meaning: "나는 것을"),
        WordDetail.Example.Chunk(text: "so", meaning: "그래서"),
        WordDetail.Example.Chunk(text: "she always travels", meaning: "그녀는 항상 이동한다"),
        WordDetail.Example.Chunk(text: "by train", meaning: "기차로"),
        WordDetail.Example.Chunk(text: "instead", meaning: "대신에")
    ]
}

private extension Array where Element == WordDetail.Example.Word {
    static let fixtureWords: Self = [
        WordDetail.Example.Word(
            word: "afraid",
            meaning: "두려워하는, 무서워하는",
            pos: "adj"
        ),
        WordDetail.Example.Word(
            word: "flying",
            meaning: "비행, 나는 것",
            pos: "n"
        ),
        WordDetail.Example.Word(
            word: "travel",
            meaning: "여행하다, 이동하다",
            pos: "v"
        ),
        WordDetail.Example.Word(
            word: "instead",
            meaning: "대신에",
            pos: "adv"
        )
    ]
}
