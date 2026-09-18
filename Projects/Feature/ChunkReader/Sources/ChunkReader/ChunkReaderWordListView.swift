import SwiftUI

import DesignSystem
import DomainInterface

struct ChunkReaderWordListView: View {
    let wordAnnotations: [Indexed<WordDetail.Example.WordAnnotation>]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .background(DesignSystemAsset.line.swiftUIColor)
                .padding(.bottom, 14)

            ChunkReaderWordRows(wordAnnotations: wordAnnotations)
        }
    }
}
