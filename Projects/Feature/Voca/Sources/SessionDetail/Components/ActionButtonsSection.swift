import SwiftUI

struct ActionButtonsSection: View {
    var body: some View {
        VStack(spacing: 12) {
            Button("학습 시작 — 4-Phase 게임", systemImage: "play.fill") {}
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .disabled(true)

            Button("단어 보기 (게임 없이 깊이 학습)", systemImage: "book") {}
                .frame(maxWidth: .infinity)
                .buttonStyle(.bordered)
                .disabled(true)
        }
    }
}
