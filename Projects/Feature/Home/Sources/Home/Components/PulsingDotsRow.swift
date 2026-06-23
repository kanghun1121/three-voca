import SwiftUI

struct PulsingDotsRow: View {
    var body: some View {
        HStack(spacing: 12) {
            PulsingDot(delay: 0)
            PulsingDot(delay: 0.18)
            PulsingDot(delay: 0.36)
        }
    }
}
