import SwiftUI

import DesignSystem

struct StageEndView: View {
    let title: String
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            GameBackground()
            StageEndContent(title: title)
        }
        .toolbar(.hidden, for: .navigationBar)
        .task {
            try? await Task.sleep(for: .seconds(1.6))
            onContinue()
        }
    }
}

// MARK: - 콘텐츠

private struct StageEndContent: View {
    let title: String

    @State private var textOffset: Double = 10
    @State private var textOpacity: Double = 0

    var body: some View {
        VStack(spacing: 28) {
            StageEndCheckMark()

            Text(title)
                .typography(DesignSystemTypography.Pretendard.extraBold32)
                .foregroundStyle(DesignSystemColor.Base.white)
                .multilineTextAlignment(.center)
                .offset(y: textOffset)
                .opacity(textOpacity)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.48).delay(0.2)) {
                textOffset = 0
                textOpacity = 1.0
            }
        }
    }
}

// MARK: - 체크 마크

private struct StageEndCheckMark: View {
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
                endRadius: 54
            )
            .frame(width: 108, height: 108)
            .scaleEffect(glowScale)
            .opacity(glowOpacity)

            Circle()
                .fill(DesignSystemColor.Base.white.opacity(0.12))
                .stroke(DesignSystemColor.Status.positive, lineWidth: 2)
                .frame(width: 84, height: 84)
                .overlay {
                    Image(systemName: "checkmark")
                        .typography(DesignSystemTypography.Pretendard.semiBold28)
                        .foregroundStyle(DesignSystemColor.Status.positive)
                }
                .scaleEffect(markScale)
                .opacity(markOpacity)
        }
        .frame(width: 108, height: 108)
        .onAppear {
            withAnimation(.spring(response: 0.52, dampingFraction: 0.55)) {
                markScale = 1.0
                markOpacity = 1.0
            }
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                    glowScale = 1.1
                    glowOpacity = 1.0
                }
            }
        }
    }
}
