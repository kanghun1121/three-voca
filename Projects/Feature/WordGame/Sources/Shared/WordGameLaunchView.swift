import SwiftUI

import DesignSystem

struct WordGameLaunchView: View {
    let onStart: () -> Void

    @State private var brandOffset: Double = 10
    @State private var brandOpacity: Double = 0
    @State private var pillBobbed = false

    var body: some View {
        ZStack {
            GameBackground()
            LaunchBrandView(offset: brandOffset, opacity: brandOpacity)
            LaunchTapHintView(bobbed: pillBobbed)
        }
        .contentShape(Rectangle())
        .onTapGesture { onStart() }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("게임 시작")
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.timingCurve(0.3, 0, 0, 1, duration: 0.62)) {
                brandOffset = 0
                brandOpacity = 1
            }
            pillBobbed = true
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
                .font(DesignSystemFontFamily.Pretendard.extraBold.swiftUIFont(size: 46))
                .foregroundStyle(Color.white)
                .kerning(-0.035 * 46)
                .shadow(color: Color(red: 0.18, green: 0.15, blue: 0.41).opacity(0.6), radius: 20, x: 0, y: 4)

            Text("단어 속으로 들어갈 시간")
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                .foregroundStyle(Color.white.opacity(0.62))
                .kerning(0.01 * 15)
        }
        .offset(y: offset)
        .opacity(opacity)
    }
}

// MARK: - 하단 탭 힌트

private struct LaunchTapHintView: View {
    let bobbed: Bool

    var body: some View {
        VStack {
            Spacer()
            LaunchPillView(bobbed: bobbed)
                .padding(.bottom, 56)
        }
    }
}

private struct LaunchPillView: View {
    let bobbed: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text("탭하여 시작")
                .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                .foregroundStyle(Color.white)

            Image(systemName: "arrow.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.10))
        .overlay {
            Capsule()
                .stroke(Color.white.opacity(0.20), lineWidth: 1)
        }
        .clipShape(Capsule())
        .offset(y: bobbed ? -4 : 0)
        .animation(
            .easeInOut(duration: 1.3)
                .repeatForever(autoreverses: true)
                .delay(0.6),
            value: bobbed
        )
    }
}
