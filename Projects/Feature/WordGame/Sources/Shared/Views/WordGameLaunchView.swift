import SwiftUI

import DesignSystem

struct WordGameLaunchView: View {
    let onStart: () -> Void

    @State private var brandOffset: Double = 10
    @State private var brandOpacity: Double = 0

    var body: some View {
        ZStack {
            GameBackground()
            LaunchBrandView(offset: brandOffset, opacity: brandOpacity)
            LaunchTapHintView()
        }
        .contentShape(Rectangle())
        .onTapGesture { onStart() }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("게임 시작")
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.timingCurve(
                0.3, 0, 0, 1,
                duration: 0.62
            )) {
                brandOffset = 0
                brandOpacity = 1
            }
        }
    }
}

// MARK: - 중앙 브랜드

private struct LaunchBrandView: View {
    let offset: Double
    let opacity: Double

    var body: some View {
        VStack(spacing: 14) {
            Text("3초 단어")
                .typography(DesignSystemTypography.Pretendard.extraBold46)
                .foregroundStyle(DesignSystemColor.Base.white)
                .shadow(
                    color: DesignSystemColor.Game.deep.opacity(0.6),
                    radius: 20,
                    x: 0,
                    y: 4
                )

            Text("단어 속으로 들어갈 시간")
                .typography(DesignSystemTypography.Pretendard.regular15)
                .foregroundStyle(DesignSystemColor.Base.white.opacity(0.62))
        }
        .offset(y: offset)
        .opacity(opacity)
    }
}

// MARK: - 하단 탭 힌트

private struct LaunchTapHintView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("탭하여 시작")
                .typography(DesignSystemTypography.Pretendard.medium15)
                .foregroundStyle(DesignSystemColor.Base.white.opacity(0.38))
                .padding(.bottom, 30)
        }
    }
}
