import SwiftUI

import DesignSystem

struct ChunkReaderMeaningLabel: View {
    let meaning: String?

    var body: some View {
        if let meaning {
            Text(meaning)
                .typography(DesignSystemTypography.Pretendard.semiBold17)
                .foregroundStyle(DesignSystemColor.Foreground.strong)
        } else {
            Text("청크를 탭하면 뜻이 나와요")
                .typography(DesignSystemTypography.Pretendard.semiBold14)
                .foregroundStyle(DesignSystemColor.Foreground.subtle)
        }
    }
}
