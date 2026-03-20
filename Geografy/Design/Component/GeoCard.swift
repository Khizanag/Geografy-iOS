import SwiftUI

struct GeoCard<Content: View>: View {
    private let cornerRadius: CGFloat
    private let shadow: GeoShadow?
    private let content: Content

    init(
        cornerRadius: CGFloat = GeoCornerRadius.medium,
        shadow: GeoShadow? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.content = content()
    }

    var body: some View {
        content
            .background(GeoColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .optionalShadow(shadow)
    }
}

// MARK: - Optional Shadow

private extension View {
    @ViewBuilder
    func optionalShadow(_ shadow: GeoShadow?) -> some View {
        if let shadow {
            self.geoShadow(shadow)
        } else {
            self
        }
    }
}
