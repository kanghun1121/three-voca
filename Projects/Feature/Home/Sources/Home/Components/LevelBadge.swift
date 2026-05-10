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
    var backgroundColor: Color {
        switch self {
        case .level1: return Color(red: 0.91, green: 0.96, blue: 0.91)
        case .level2: return Color(red: 0.89, green: 0.95, blue: 1.00)
        case .level3: return Color(red: 0.89, green: 0.95, blue: 1.00)
        case .unknown: return .gray.opacity(0.15)
        }
    }

    var foregroundColor: Color {
        switch self {
        case .level1: return Color(red: 0.18, green: 0.49, blue: 0.20)
        case .level2: return Color(red: 0.08, green: 0.40, blue: 0.75)
        case .level3: return Color(red: 0.08, green: 0.40, blue: 0.75)
        case .unknown: return .gray
        }
    }
}

#Preview {
    HStack(spacing: 8) {
        LevelBadge(text: "L1", color: .level1)
        LevelBadge(text: "L2", color: .level2)
        LevelBadge(text: "L3", color: .level3)
    }
    .padding()
}
