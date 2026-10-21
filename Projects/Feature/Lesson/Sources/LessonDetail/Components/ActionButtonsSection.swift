import SwiftUI

import DesignSystem

struct ActionButtonsSection: View {
    let onGameTapped: () -> Void
    let onWordListTapped: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Button(action: onGameTapped) {
                Label("학습 게임 시작", systemImage: "play.fill")
                    .typography(DesignSystemTypography.Pretendard.bold17)
                    .foregroundStyle(DesignSystemColor.Base.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(DesignSystemColor.Game.base)
                    .clipShape(.rect(cornerRadius: 14))
            }
            .buttonStyle(.plain)

            Button(action: onWordListTapped) {
                Label("단어 보기", systemImage: "book")
                    .typography(DesignSystemTypography.Pretendard.semiBold17)
                    .foregroundStyle(DesignSystemColor.Foreground.strong)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(DesignSystemColor.Background.base)
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(DesignSystemColor.Border.default, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
        }
    }
}
