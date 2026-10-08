import SwiftUI

import DesignSystem

struct WordCardTagPillView: View {
    enum Kind {
        case know
        case time
    }

    @ScaledMetric private var pillTextSize: CGFloat = DesignSystemTypography.Pretendard.extraBold10.size

    let kind: Kind

    var body: some View {
        switch kind {
        case .know:
            Text("✓ 안다")
                .typography(DesignSystemTypography.Pretendard.extraBold10.scaled(to: CGFloat(pillTextSize)))
                .foregroundStyle(DesignSystemColor.Status.positive)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(DesignSystemColor.Status.positive.opacity(0.12))
                .clipShape(Capsule())
        case .time:
            Text("3s")
                .typography(DesignSystemTypography.Pretendard.extraBold10.scaled(to: CGFloat(pillTextSize)))
                .foregroundStyle(DesignSystemColor.Status.negativeText)
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(DesignSystemColor.Status.negative.opacity(0.12))
                .clipShape(Capsule())
        }
    }
}
