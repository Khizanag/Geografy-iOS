import SwiftUI

enum GeoShadow {
    case card
    case elevated
    case subtle
}

// MARK: - ViewModifier

extension GeoShadow {
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

// MARK: - View Extension

extension View {
    func geoShadow(_ style: GeoShadow = .card) -> some View {
        shadow(
            color: .black.opacity(style.opacity),
            radius: style.radius,
            x: 0,
            y: style.y
        )
    }
}
