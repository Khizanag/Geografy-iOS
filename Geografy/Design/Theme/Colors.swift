import SwiftUI

enum GeoColors {
    static let background = Color("GeoBackground")
    static let cardBackground = Color("GeoCardBackground")
    static let cardBackgroundHighlighted = Color("GeoCardBackgroundHighlighted")

    static let accent = Color("GeoAccent")
    static let accentDark = Color("GeoAccentDark")

    static let textPrimary = Color("GeoTextPrimary")
    static let textSecondary = Color("GeoTextSecondary")
    static let textTertiary = Color("GeoTextTertiary")

    static let ocean = Color("GeoOcean")

    static let success = Color("GeoSuccess")
    static let warning = Color("GeoWarning")
    static let error = Color("GeoError")

    static let indigo = Color("GeoIndigo")
    static let blue = Color("GeoBlue")
    static let purple = Color("GeoPurple")
    static let orange = Color("GeoOrange")

    static let mapColors: [Color] = [
        Color(hex: "9B59B6"),
        Color(hex: "E67E22"),
        Color(hex: "3498DB"),
        Color(hex: "E74C3C"),
        Color(hex: "2ECC71"),
        Color(hex: "F1C40F"),
        Color(hex: "00BCD4"),
        Color(hex: "E91E63"),
        Color(hex: "009688"),
        Color(hex: "FF6B9D"),
        Color(hex: "5C6BC0"),
        Color(hex: "FFB300"),
    ]
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
