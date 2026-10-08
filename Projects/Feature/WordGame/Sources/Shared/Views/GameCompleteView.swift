import SwiftUI

import DesignSystem

struct GameCompleteView: View {
    let wordCount: Int
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            GameBackground()
            GameCompleteContent(wordCount: wordCount)
        }
        .contentShape(Rectangle())
        .onTapGesture { onDismiss() }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("학습 종료")
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - 콘텐츠

private struct GameCompleteContent: View {
    let wordCount: Int

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            GameCompleteCheckMark()

            GameCompleteTitleView(wordCount: wordCount)
                .padding(.top, 34)

            Spacer()

            GameCompleteTapHint()
        }
    }
}

// MARK: - 체크 마크

private struct GameCompleteCheckMark: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var markScale: Double = 0.6
    @State private var markOpacity: Double = 0
    @State private var glowScale: Double = 0.9
    @State private var glowOpacity: Double = 0.5

    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    DesignSystemColor.Status.positive.opacity(0.35),
                    DesignSystemColor.Status.positive.opacity(0)
                ]),
                center: .center,
                startRadius: 0,
                endRadius: 60
            )
            .frame(width: 120, height: 120)
            .scaleEffect(glowScale)
            .opacity(glowOpacity)

            Circle()
                .fill(DesignSystemColor.Base.white.opacity(0.12))
                .stroke(DesignSystemColor.Status.positive, lineWidth: 2)
                .frame(width: 92, height: 92)
                .overlay {
                    Image(systemName: "checkmark")
                        .typography(DesignSystemTypography.Pretendard.semiBold32)
                        .foregroundStyle(DesignSystemColor.Status.positive)
                }
                .scaleEffect(markScale)
                .opacity(markOpacity)
        }
        .frame(width: 120, height: 120)
        .onAppear {
            withAnimation(.spring(response: 0.56, dampingFraction: 0.55)) {
                markScale = 1.0
                markOpacity = 1.0
            }
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                    glowScale = 1.1
                    glowOpacity = 1.0
                }
            }
        }
    }
}

// MARK: - 타이틀 · 서브타이틀

private struct GameCompleteTitleView: View {
    let wordCount: Int

    @State private var offset: Double = 12
    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 12) {
            Text("오늘 학습 완료")
                .typography(DesignSystemTypography.Pretendard.extraBold30)
                .foregroundStyle(DesignSystemColor.Base.white)

            Text("단어 \(wordCount)개를 모두 끝냈어요")
                .typography(DesignSystemTypography.Content.gameCompletionSubtitle)
                .foregroundStyle(DesignSystemColor.Base.white.opacity(0.62))
                .multilineTextAlignment(.center)
        }
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.52).delay(0.2)) {
                offset = 0
                opacity = 1.0
            }
        }
    }
}

// MARK: - 탭 힌트

private struct GameCompleteTapHint: View {
    var body: some View {
        Text("탭하면 학습을 종료합니다.")
            .typography(DesignSystemTypography.Pretendard.medium15)
            .foregroundStyle(DesignSystemColor.Base.white.opacity(0.38))
            .padding(.bottom, 30)
    }
}
