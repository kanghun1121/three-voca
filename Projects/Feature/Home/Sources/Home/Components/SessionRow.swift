import SwiftUI

import DesignSystem

struct SessionRow: View {
    let presentationModel: SessionRowPresentationModel

    private var isCompleted: Bool { presentationModel.icon.isCompleted }

    var body: some View {
        HStack(spacing: 11) {
            SessionCircleBadge(
                sessionNumber: presentationModel.sessionNumber,
                isCompleted: isCompleted
            )
            Text("\(presentationModel.sessionNumber)번째 세션")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 14.5))
                .foregroundStyle(
                    isCompleted
                        ? DesignSystemAsset.fgStrong.swiftUIColor
                        : DesignSystemAsset.fgMuted.swiftUIColor
                )
            Spacer()
            if isCompleted {
                Text("완료")
                    .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 12.5))
                    .foregroundStyle(DesignSystemAsset.fgSubtle.swiftUIColor)
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SessionRow(presentationModel: SessionRowPresentationModel(
            id: 1,
            sessionNumber: 1,
            icon: .completedHigh
        ))
        SessionRow(presentationModel: SessionRowPresentationModel(
            id: 2,
            sessionNumber: 2,
            icon: .completedLow
        ))
        SessionRow(presentationModel: SessionRowPresentationModel(
            id: 3,
            sessionNumber: 5,
            icon: .notStarted
        ))
        SessionRow(presentationModel: SessionRowPresentationModel(
            id: 4,
            sessionNumber: 6,
            icon: .notStarted
        ))
    }
    .padding()
}
