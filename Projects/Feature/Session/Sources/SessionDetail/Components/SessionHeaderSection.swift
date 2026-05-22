import SwiftUI

struct SessionHeaderSection: View {
    let levelHeader: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(levelHeader)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.indigo)
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
