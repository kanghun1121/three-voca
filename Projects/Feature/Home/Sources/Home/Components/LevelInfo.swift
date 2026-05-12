import SwiftUI

struct LevelInfo: View {
    let name: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.subheadline)
                .bold()
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
