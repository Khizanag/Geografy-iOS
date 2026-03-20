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

        static let indigo = SwiftUI.Color("Indigo")
        static let blue = SwiftUI.Color("Blue")
        static let purple = SwiftUI.Color("Purple")
        static let orange = SwiftUI.Color("Orange")

        static let mapColors: [SwiftUI.Color] = [
            // Reds
            SwiftUI.Color(hex: "E74C3C"),
            SwiftUI.Color(hex: "C0392B"),
            SwiftUI.Color(hex: "FF6B6B"),
            SwiftUI.Color(hex: "D32F2F"),
            // Pinks
            SwiftUI.Color(hex: "E91E63"),
            SwiftUI.Color(hex: "FF6B9D"),
            SwiftUI.Color(hex: "EC407A"),
            SwiftUI.Color(hex: "F48FB1"),
            // Purples
            SwiftUI.Color(hex: "9B59B6"),
            SwiftUI.Color(hex: "AB47BC"),
            SwiftUI.Color(hex: "7E57C2"),
            SwiftUI.Color(hex: "CE93D8"),
            // Indigos
            SwiftUI.Color(hex: "5C6BC0"),
            SwiftUI.Color(hex: "3F51B5"),
            SwiftUI.Color(hex: "7986CB"),
            // Blues
            SwiftUI.Color(hex: "3498DB"),
            SwiftUI.Color(hex: "42A5F5"),
            SwiftUI.Color(hex: "29B6F6"),
            SwiftUI.Color(hex: "1565C0"),
            SwiftUI.Color(hex: "90CAF9"),
            // Cyans
            SwiftUI.Color(hex: "00BCD4"),
            SwiftUI.Color(hex: "26C6DA"),
            SwiftUI.Color(hex: "0097A7"),
            // Teals
            SwiftUI.Color(hex: "1ABC9C"),
            SwiftUI.Color(hex: "26A69A"),
            SwiftUI.Color(hex: "009688"),
            // Greens
            SwiftUI.Color(hex: "2ECC71"),
            SwiftUI.Color(hex: "66BB6A"),
            SwiftUI.Color(hex: "8BC34A"),
            SwiftUI.Color(hex: "4CAF50"),
            SwiftUI.Color(hex: "81C784"),
            SwiftUI.Color(hex: "388E3C"),
            // Limes
            SwiftUI.Color(hex: "CDDC39"),
            SwiftUI.Color(hex: "D4E157"),
            // Yellows
            SwiftUI.Color(hex: "FFEB3B"),
            SwiftUI.Color(hex: "FDD835"),
            SwiftUI.Color(hex: "FFF176"),
            // Ambers
            SwiftUI.Color(hex: "FFB300"),
            SwiftUI.Color(hex: "FFA726"),
            SwiftUI.Color(hex: "FFD54F"),
            // Oranges
            SwiftUI.Color(hex: "F39C12"),
            SwiftUI.Color(hex: "FF5722"),
            SwiftUI.Color(hex: "FF7043"),
            SwiftUI.Color(hex: "E65100"),
            // Browns
            SwiftUI.Color(hex: "8D6E63"),
            SwiftUI.Color(hex: "A1887F"),
            SwiftUI.Color(hex: "6D4C41"),
            // Grays
            SwiftUI.Color(hex: "78909C"),
            SwiftUI.Color(hex: "90A4AE"),
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
