import SwiftUI

public extension DesignSystem {
    enum Color {
        public static let background = SwiftUI.Color("Background")
        public static let cardBackground = SwiftUI.Color("CardBackground")
        public static let cardBackgroundHighlighted = SwiftUI.Color("CardBackgroundHighlighted")

        public static let accent = SwiftUI.Color("Accent")
        public static let accentDark = SwiftUI.Color("AccentDark")

        public static let textPrimary = SwiftUI.Color("TextPrimary")
        public static let textSecondary = SwiftUI.Color("TextSecondary")
        public static let textTertiary = SwiftUI.Color("TextTertiary")

        public static let iconPrimary = SwiftUI.Color("IconPrimary")
        public static let iconSecondary = SwiftUI.Color("IconSecondary")

        public static let onAccent = SwiftUI.Color("OnAccent")

        public static let ocean = SwiftUI.Color("Ocean")

        public static let success = SwiftUI.Color("Success")
        public static let warning = SwiftUI.Color("Warning")
        public static let error = SwiftUI.Color("Error")

        public static let indigo = SwiftUI.Color("GeoIndigo")
        public static let blue = SwiftUI.Color("GeoBlue")
        public static let purple = SwiftUI.Color("GeoPurple")
        public static let orange = SwiftUI.Color("GeoOrange")

        // Semantic tokens for adaptive borders, overlays, and scrim
        public static let dividerSubtle = SwiftUI.Color.primary.opacity(0.06)
        public static let overlayScrim = SwiftUI.Color.primary.opacity(0.4)

        // 8 perceptually distinct hues, each ~45° apart on the color wheel,
        // tuned for vibrant appearance on a dark background.
        public static let mapColors: [SwiftUI.Color] = [
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
public extension Color {
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
