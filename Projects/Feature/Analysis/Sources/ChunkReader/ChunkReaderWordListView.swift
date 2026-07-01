import SwiftUI

struct ChunkReaderWordListView: View {
    let words: [ChunkReaderPresentationModel.WordRow]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ChunkReaderWordListHeader()
            ChunkReaderWordRows(words: words)
        }
    }
}
