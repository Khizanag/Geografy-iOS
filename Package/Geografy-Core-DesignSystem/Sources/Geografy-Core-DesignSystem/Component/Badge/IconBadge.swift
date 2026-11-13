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

        var iconPoints: CGFloat {
            switch self {
            case .small: 14
            case .medium: 18
            case .large: 24
            case .hero: 36
            }
        }
    }

    // MARK: - Properties
    @ScaledMetric(relativeTo: .body) private var textScale: CGFloat = 1

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
            .font(.system(size: size.iconPoints * scale, weight: .semibold))
            .foregroundStyle(color)
            .frame(width: size.diameter * scale, height: size.diameter * scale)
            .background(color.opacity(0.15), in: Circle())
            .accessibilityHidden(true)
    }

    // Grows with Text Size, capped so a badge never crowds out the text beside it.
    private var scale: CGFloat {
        min(textScale, 1.6)
    }
}
