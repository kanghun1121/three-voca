import SwiftUI

struct ProgressFill: View {
    let ratio: Double

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(HomeColors.progressTrack)
            RoundedRectangle(cornerRadius: 2)
                .fill(HomeColors.brandGreen)
                .scaleEffect(x: max(0, min(1, ratio)), anchor: .leading)
        }
        .frame(height: 4)
    }
}
