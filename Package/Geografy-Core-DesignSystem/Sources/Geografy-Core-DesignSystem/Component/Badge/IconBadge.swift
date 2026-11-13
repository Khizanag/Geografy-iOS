import SwiftUI

/// An SF Symbol on a soft circle of its own color — the app's one icon badge, at four sizes.
public struct IconBadge: View {
    // MARK: - Size
    public enum Size {
        /// List rows and compact cards.
        case small
        /// Section cards and banners.
        case medium
        /// Feature cards and setup screens.
        case large
        /// The single icon heading a screen, sheet, or result.
        case hero

        var diameter: CGFloat {
            switch self {
            case .small: 36
            case .medium: 44
            case .large: 56
            case .hero: 96
            }
        }

        var font: Font {
            switch self {
            case .small: DesignSystem.Font.iconXS
            case .medium: DesignSystem.Font.iconSmall
            case .large: DesignSystem.Font.iconMedium
            case .hero: DesignSystem.Font.iconXL
            }
        }
    }

    // MARK: - Properties
    private let systemImage: String
    private let color: Color
    private let size: Size

    // MARK: - Init
    public init(_ systemImage: String, color: Color = DesignSystem.Color.accent, size: Size = .medium) {
        self.systemImage = systemImage
        self.color = color
        self.size = size
    }

    // MARK: - Body
    public var body: some View {
        Image(systemName: systemImage)
            .font(size.font)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .frame(width: size.diameter, height: size.diameter)
            .background(color.opacity(0.15), in: Circle())
            .accessibilityHidden(true)
    }
}
