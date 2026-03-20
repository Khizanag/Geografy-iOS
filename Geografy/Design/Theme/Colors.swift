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

        static let onAccent = SwiftUI.Color("GeoOnAccent")

        static let ocean = SwiftUI.Color("GeoOcean")

        static let success = SwiftUI.Color("GeoSuccess")
        static let warning = SwiftUI.Color("GeoWarning")
        static let error = SwiftUI.Color("GeoError")

        static let indigo = SwiftUI.Color("GeoIndigo")
        static let blue = SwiftUI.Color("GeoBlue")
        static let purple = SwiftUI.Color("GeoPurple")
        static let orange = SwiftUI.Color("GeoOrange")

        static let mapColors: [SwiftUI.Color] = [
            SwiftUI.Color(hex: "E74C3C"),
            SwiftUI.Color(hex: "3498DB"),
            SwiftUI.Color(hex: "2ECC71"),
            SwiftUI.Color(hex: "F39C12"),
            SwiftUI.Color(hex: "9B59B6"),
            SwiftUI.Color(hex: "1ABC9C"),
            SwiftUI.Color(hex: "E91E63"),
            SwiftUI.Color(hex: "00BCD4"),
            SwiftUI.Color(hex: "FF5722"),
            SwiftUI.Color(hex: "8BC34A"),
            SwiftUI.Color(hex: "5C6BC0"),
            SwiftUI.Color(hex: "FFEB3B"),
            SwiftUI.Color(hex: "FF6B9D"),
            SwiftUI.Color(hex: "26A69A"),
            SwiftUI.Color(hex: "AB47BC"),
            SwiftUI.Color(hex: "42A5F5"),
            SwiftUI.Color(hex: "EF5350"),
            SwiftUI.Color(hex: "66BB6A"),
            SwiftUI.Color(hex: "FFA726"),
            SwiftUI.Color(hex: "7E57C2"),
            SwiftUI.Color(hex: "29B6F6"),
            SwiftUI.Color(hex: "EC407A"),
            SwiftUI.Color(hex: "26C6DA"),
            SwiftUI.Color(hex: "D4E157"),
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
