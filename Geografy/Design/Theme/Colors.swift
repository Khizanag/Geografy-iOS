import SwiftUI

enum GeoColors {
    static let background = Color(hex: "1C1C1E")
    static let cardBackground = Color(hex: "2C2C2E")
    static let cardBackgroundHighlighted = Color(hex: "3C3C3E")

    static let accent = Color(hex: "2EC4B6")
    static let accentDark = Color(hex: "1A7A6E")

    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "8E8E93")
    static let textTertiary = Color(hex: "636366")

    static let ocean = Color(hex: "0D1117")

    static let success = Color(hex: "34C759")
    static let warning = Color(hex: "FF9500")
    static let error = Color(hex: "FF3B30")

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
