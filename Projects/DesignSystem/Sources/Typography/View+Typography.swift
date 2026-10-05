import SwiftUI

public extension View {
    func typography(_ style: DesignSystemTypography) -> some View {
        font(style.font)
    }
}
