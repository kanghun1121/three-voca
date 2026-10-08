import SwiftUI
import UIKit

/// A text style defining font family, size and weight.
public struct DesignSystemTypography: Sendable {
    public let size: CGFloat
    private let family: Family
    private let scalesWithBody: Bool
    private let usesMonospacedDigits: Bool

    enum Weight: Sendable, Equatable {
        case regular, medium, semiBold, bold, extraBold
    }

    enum Family: Sendable {
        case pretendard(Weight)
        case mono(Weight)
    }

    init(
        family: Family,
        size: CGFloat,
        scalesWithBody: Bool = false,
        monospacedDigits: Bool = false
    ) {
        self.family = family
        self.size = size
        self.scalesWithBody = scalesWithBody
        usesMonospacedDigits = monospacedDigits
    }

    public var font: Font {
        let font: Font = scalesWithBody ? .custom(uiFont.fontName, size: size, relativeTo: .body) : Font(uiFont)
        return usesMonospacedDigits ? font.monospacedDigit() : font
    }

    public func scaled(to size: CGFloat) -> Self {
        Self(
            family: family,
            size: size,
            scalesWithBody: scalesWithBody,
            monospacedDigits: usesMonospacedDigits
        )
    }

    func monospacedDigits() -> Self {
        Self(
            family: family,
            size: size,
            scalesWithBody: scalesWithBody,
            monospacedDigits: true
        )
    }

    public var italicFont: Font { font.italic() }

    private var uiFont: UIFont {
        switch family {
        case .pretendard(let weight):
            let resource: DesignSystemFontConvertible
            switch weight {
            case .regular: resource = DesignSystemFontFamily.Pretendard.regular
            case .medium: resource = DesignSystemFontFamily.Pretendard.medium
            case .semiBold: resource = DesignSystemFontFamily.Pretendard.semiBold
            case .bold: resource = DesignSystemFontFamily.Pretendard.bold
            case .extraBold: resource = DesignSystemFontFamily.Pretendard.extraBold
            }
            return resource.font(size: size)
        case .mono(let weight):
            let resource = weight == .bold
                ? DesignSystemFontFamily.RobotoMono.bold
                : DesignSystemFontFamily.RobotoMono.regular
            return resource.font(size: size)
        }
    }
}
