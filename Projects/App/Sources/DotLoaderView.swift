import SwiftUI

struct DotLoaderView: View {
    var body: some View {
        HStack(spacing: 9) {
            DotView(delay: 0)
            DotView(delay: 0.16)
            DotView(delay: 0.32)
        }
    }
}
