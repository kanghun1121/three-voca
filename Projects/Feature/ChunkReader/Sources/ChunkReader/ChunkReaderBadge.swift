import SwiftUI

import DesignSystem

struct ChunkReaderBadge: View {
    let icon: String
    let label: String

    var body: some View {
        Label {
            Text(label)
                .typography(DesignSystemTypography.Pretendard.bold11_5)
        } icon: {
            Image(systemName: icon)
                .typography(DesignSystemTypography.Pretendard.regular12)
        }
        .foregroundStyle(DesignSystemColor.Accent.selectedBlueText)
        .padding(.init(top: 5, leading: 9, bottom: 5, trailing: 9))
        .overlay {
            Capsule()
                .stroke(DesignSystemColor.Accent.selectedBlue.opacity(0.4), lineWidth: 1)
        }
    }
}
