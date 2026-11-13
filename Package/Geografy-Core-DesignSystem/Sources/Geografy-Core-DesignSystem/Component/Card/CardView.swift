import SwiftUI

public struct CardView<Content: View>: View {
    // MARK: - Properties
    @Environment(\.colorSchemeContrast) private var contrast

    private let cornerRadius: CGFloat
    private let shadow: DesignSystem.Shadow?
    private let content: Content

    // MARK: - Init
    public init(
        cornerRadius: CGFloat = DesignSystem.CornerRadius.extraLarge,
        shadow: DesignSystem.Shadow? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.content = content()
    }

    // MARK: - Body
    public var body: some View {
        content
            .background(DesignSystem.Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                // At increased contrast a card needs an edge, not just a fill a shade off the background.
                if contrast == .increased {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(DesignSystem.Color.dividerSubtle, lineWidth: 1)
                }
            }
            .optionalShadow(shadow)
    }
}

// MARK: - Optional Shadow
private extension View {
    @ViewBuilder
    func optionalShadow(_ shadow: DesignSystem.Shadow?) -> some View {
        if let shadow {
            self.geoShadow(shadow)
        } else {
            self
        }
    }
}
