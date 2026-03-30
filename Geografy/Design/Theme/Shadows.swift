import SwiftUI

extension DesignSystem {
    enum Shadow {
        case card
        case elevated
        case subtle
    }
}

// MARK: - ViewModifier
extension DesignSystem.Shadow {
    var radius: CGFloat {
        switch self {
        case .card: 8
        case .elevated: 16
        case .subtle: 4
        }
    }

    var y: CGFloat {
        switch self {
        case .card: 4
        case .elevated: 8
        case .subtle: 2
        }
    }

    var opacity: Double {
        switch self {
        case .card: 0.3
        case .elevated: 0.4
        case .subtle: 0.2
        }
    }
}

// MARK: - ViewModifier
struct GeoShadowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    let style: DesignSystem.Shadow

    func body(content: Content) -> some View {
        let adjustedOpacity = colorScheme == .dark ? style.opacity * 0.4 : style.opacity
        content.shadow(
            color: .black.opacity(adjustedOpacity),
            radius: style.radius,
            x: 0,
            y: style.y
        )
    }
}

// MARK: - View Extension
extension View {
    func geoShadow(_ style: DesignSystem.Shadow = .card) -> some View {
        modifier(GeoShadowModifier(style: style))
    }
}
