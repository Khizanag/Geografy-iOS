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

        // Interleaved by hue so consecutive indices are maximally different
        static let mapColors: [SwiftUI.Color] = [
            // Round 1: one from each hue group
            SwiftUI.Color(hex: "E74C3C"), // red
            SwiftUI.Color(hex: "3498DB"), // blue
            SwiftUI.Color(hex: "2ECC71"), // green
            SwiftUI.Color(hex: "FFB300"), // amber
            SwiftUI.Color(hex: "9B59B6"), // purple
            SwiftUI.Color(hex: "00BCD4"), // cyan
            SwiftUI.Color(hex: "FF5722"), // orange
            SwiftUI.Color(hex: "E91E63"), // pink
            SwiftUI.Color(hex: "1ABC9C"), // teal
            SwiftUI.Color(hex: "CDDC39"), // lime
            SwiftUI.Color(hex: "5C6BC0"), // indigo
            SwiftUI.Color(hex: "FFEB3B"), // yellow
            // Round 2: second shade from each group
            SwiftUI.Color(hex: "C0392B"), // red dark
            SwiftUI.Color(hex: "42A5F5"), // blue light
            SwiftUI.Color(hex: "66BB6A"), // green light
            SwiftUI.Color(hex: "FFA726"), // amber light
            SwiftUI.Color(hex: "AB47BC"), // purple light
            SwiftUI.Color(hex: "26C6DA"), // cyan light
            SwiftUI.Color(hex: "F39C12"), // orange warm
            SwiftUI.Color(hex: "EC407A"), // pink med
            SwiftUI.Color(hex: "26A69A"), // teal light
            SwiftUI.Color(hex: "D4E157"), // lime light
            SwiftUI.Color(hex: "3F51B5"), // indigo deep
            SwiftUI.Color(hex: "FDD835"), // yellow med
            // Round 3: third shade
            SwiftUI.Color(hex: "FF6B6B"), // red light
            SwiftUI.Color(hex: "1565C0"), // blue deep
            SwiftUI.Color(hex: "8BC34A"), // green lime
            SwiftUI.Color(hex: "FFD54F"), // amber pale
            SwiftUI.Color(hex: "7E57C2"), // purple deep
            SwiftUI.Color(hex: "0097A7"), // cyan dark
            SwiftUI.Color(hex: "FF7043"), // orange light
            SwiftUI.Color(hex: "FF6B9D"), // pink light
            SwiftUI.Color(hex: "009688"), // teal dark
            SwiftUI.Color(hex: "7986CB"), // indigo light
            SwiftUI.Color(hex: "FFF176"), // yellow pale
            SwiftUI.Color(hex: "4CAF50"), // green solid
            // Round 4: remaining
            SwiftUI.Color(hex: "D32F2F"), // red deep
            SwiftUI.Color(hex: "29B6F6"), // blue sky
            SwiftUI.Color(hex: "81C784"), // green pale
            SwiftUI.Color(hex: "E65100"), // orange dark
            SwiftUI.Color(hex: "CE93D8"), // purple pale
            SwiftUI.Color(hex: "F48FB1"), // pink pale
            SwiftUI.Color(hex: "388E3C"), // green dark
            SwiftUI.Color(hex: "90CAF9"), // blue pale
            SwiftUI.Color(hex: "8D6E63"), // brown
            SwiftUI.Color(hex: "78909C"), // gray blue
            SwiftUI.Color(hex: "A1887F"), // brown light
            SwiftUI.Color(hex: "6D4C41"), // brown dark
            SwiftUI.Color(hex: "90A4AE"), // gray light
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
