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
        /// Land that isn't highlighted on a map, such as non-members or countries not yet independent.
        public static let mapLandMuted = SwiftUI.Color("MapLandMuted")

        public static let success = SwiftUI.Color("Success")
        public static let warning = SwiftUI.Color("Warning")
        /// The app's one red: the system red that menus and dialogs give `role: .destructive` labels, so icons and
        /// labels drawn by the app match those drawn by the system.
        public static let error = SwiftUI.Color.red
        /// Deleting, signing out, or resetting. The same red as ``error``, named for what it marks.
        public static let destructive = error

        public static let indigo = SwiftUI.Color("GeoIndigo")
        public static let blue = SwiftUI.Color("GeoBlue")
        public static let purple = SwiftUI.Color("GeoPurple")
        public static let orange = SwiftUI.Color("GeoOrange")
        public static let pink = SwiftUI.Color("GeoPink")
        public static let teal = SwiftUI.Color("GeoTeal")

        // Semantic tokens for adaptive borders, overlays, and scrim
        public static let dividerSubtle = SwiftUI.Color("DividerSubtle")
        /// Dims what's behind a modal card. Black in both appearances: the primary color is white in Dark Mode,
        /// which would brighten the screen instead.
        public static let overlayScrim = SwiftUI.Color.black.opacity(DesignSystem.Opacity.half)
        /// The outline of a pin or marker on a map, white in both appearances so it stands out on any land color.
        public static let markerOutline = SwiftUI.Color.white
        /// The shadow under a map marker, black in both appearances.
        public static let markerShadow = SwiftUI.Color.black.opacity(DesignSystem.Opacity.soft)

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

// Color(hex:) is provided by GeografyCore
