import SwiftUI

struct CardView<Content: View>: View {
    private let cornerRadius: CGFloat
    private let shadow: DesignSystem.Shadow?
    private let content: Content

    init(
        cornerRadius: CGFloat = DesignSystem.CornerRadius.medium,
        shadow: DesignSystem.Shadow? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.content = content()
    }

    var body: some View {
        content
            .background(DesignSystem.Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
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
