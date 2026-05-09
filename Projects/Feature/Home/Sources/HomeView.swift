import SwiftUI

public struct HomeView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            Text("Home")
                .font(.largeTitle)
                .bold()
            Text("Feature/Home placeholder")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
