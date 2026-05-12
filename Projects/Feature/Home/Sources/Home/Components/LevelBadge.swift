import SwiftUI

struct LevelBadge: View {
    let text: String
    let color: LevelBadgeColor

    private var letterPart: String { String(text.prefix(1)) }
    private var numberPart: String { String(text.dropFirst()) }

    var body: some View {
        VStack(spacing: 0) {
            Text(letterPart)
                .font(.caption2)
                .foregroundStyle(color.foregroundColor)
            Text(numberPart)
                .font(.title3)
                .bold()
                .foregroundStyle(color.foregroundColor)
        }
        .frame(width: 36, height: 36)
        .background(color.backgroundColor)
        .clipShape(.rect(cornerRadius: 8))
    }
}

extension LevelBadgeColor {
    var backgroundColor: Color { HomeColors.badgeBackground(self) }
    var foregroundColor: Color { HomeColors.badgeForeground(self) }
}

#Preview {
    HStack(spacing: 8) {
        LevelBadge(text: "L1", color: .level1)
        LevelBadge(text: "L2", color: .level2)
        LevelBadge(text: "L3", color: .level3)
        LevelBadge(text: "L4", color: .level4)
    }
    .padding()
}

#Preview("다크 모드") {
    HStack(spacing: 8) {
        LevelBadge(text: "L1", color: .level1)
        LevelBadge(text: "L2", color: .level2)
        LevelBadge(text: "L3", color: .level3)
        LevelBadge(text: "L4", color: .level4)
    }
    .padding()
    .preferredColorScheme(.dark)
}
