import SwiftUI

extension DesignSystem {
    enum Color {
        static let background = SwiftUI.Color("Background")
        static let cardBackground = SwiftUI.Color("CardBackground")
        static let cardBackgroundHighlighted = SwiftUI.Color("CardBackgroundHighlighted")

        static let accent = SwiftUI.Color("Accent")
        static let accentDark = SwiftUI.Color("AccentDark")

        static let textPrimary = SwiftUI.Color("TextPrimary")
        static let textSecondary = SwiftUI.Color("TextSecondary")
        static let textTertiary = SwiftUI.Color("TextTertiary")

        static let iconPrimary = SwiftUI.Color("IconPrimary")
        static let iconSecondary = SwiftUI.Color("IconSecondary")

        static let onAccent = SwiftUI.Color("OnAccent")

        static let ocean = SwiftUI.Color("Ocean")

        static let success = SwiftUI.Color("Success")
        static let warning = SwiftUI.Color("Warning")
        static let error = SwiftUI.Color("Error")

        static let indigo = SwiftUI.Color("GeoIndigo")
        static let blue = SwiftUI.Color("GeoBlue")
        static let purple = SwiftUI.Color("GeoPurple")
        static let orange = SwiftUI.Color("GeoOrange")

        // Semantic tokens for adaptive borders, overlays, and scrim
        static let dividerSubtle = SwiftUI.Color.primary.opacity(0.06)
        static let overlayScrim = SwiftUI.Color.primary.opacity(0.4)

        // 8 perceptually distinct hues, each ~45° apart on the color wheel,
        // tuned for vibrant appearance on a dark background.
        static let mapColors: [SwiftUI.Color] = [
            SwiftUI.Color(hex: "E05C5C"), // red
            SwiftUI.Color(hex: "4AADE8"), // blue
            SwiftUI.Color(hex: "4DBE6C"), // green
            SwiftUI.Color(hex: "E8B83A"), // amber
            SwiftUI.Color(hex: "9B6BCE"), // purple
            SwiftUI.Color(hex: "3DBDB5"), // teal
            SwiftUI.Color(hex: "E87E40"), // orange
            SwiftUI.Color(hex: "D464A8"), // pink
        ]
    }
}

// MARK: - Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 1
            g = 1
            b = 1
        }

        self.init(red: r, green: g, blue: b)
    }
}
