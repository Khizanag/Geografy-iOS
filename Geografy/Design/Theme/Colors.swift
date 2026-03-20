import SwiftUI

extension DesignSystem {
    enum Color {
        static let background = SwiftUI.Color("GeoBackground")
        static let cardBackground = SwiftUI.Color("GeoCardBackground")
        static let cardBackgroundHighlighted = SwiftUI.Color("GeoCardBackgroundHighlighted")

        static let accent = SwiftUI.Color("GeoAccent")
        static let accentDark = SwiftUI.Color("GeoAccentDark")

        static let textPrimary = SwiftUI.Color("GeoTextPrimary")
        static let textSecondary = SwiftUI.Color("GeoTextSecondary")
        static let textTertiary = SwiftUI.Color("GeoTextTertiary")

        static let iconPrimary = SwiftUI.Color("GeoIconPrimary")
        static let iconSecondary = SwiftUI.Color("GeoIconSecondary")

        static let ocean = SwiftUI.Color("GeoOcean")

        static let success = SwiftUI.Color("GeoSuccess")
        static let warning = SwiftUI.Color("GeoWarning")
        static let error = SwiftUI.Color("GeoError")

        static let indigo = SwiftUI.Color("GeoIndigo")
        static let blue = SwiftUI.Color("GeoBlue")
        static let purple = SwiftUI.Color("GeoPurple")
        static let orange = SwiftUI.Color("GeoOrange")

        static let mapColors: [SwiftUI.Color] = [
            SwiftUI.Color(hex: "9B59B6"),
            SwiftUI.Color(hex: "E67E22"),
            SwiftUI.Color(hex: "3498DB"),
            SwiftUI.Color(hex: "E74C3C"),
            SwiftUI.Color(hex: "2ECC71"),
            SwiftUI.Color(hex: "F1C40F"),
            SwiftUI.Color(hex: "00BCD4"),
            SwiftUI.Color(hex: "E91E63"),
            SwiftUI.Color(hex: "009688"),
            SwiftUI.Color(hex: "FF6B9D"),
            SwiftUI.Color(hex: "5C6BC0"),
            SwiftUI.Color(hex: "FFB300"),
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
