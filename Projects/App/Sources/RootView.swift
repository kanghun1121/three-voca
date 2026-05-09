import SwiftUI

struct RootView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("FiveVoca")
                .font(.largeTitle)
                .bold()
            Text("Bootstrap Complete")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    RootView()
}
