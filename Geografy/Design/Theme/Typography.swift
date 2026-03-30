import SwiftUI

extension DesignSystem {
    enum Font {
        // MARK: - Standard Scale
        static let largeTitle: SwiftUI.Font = .system(size: 34, weight: .bold)
        static let title: SwiftUI.Font = .system(size: 28, weight: .bold)
        static let title2: SwiftUI.Font = .system(size: 22, weight: .semibold)
        static let title3: SwiftUI.Font = .system(size: 20, weight: .semibold)
        static let headline: SwiftUI.Font = .system(size: 17, weight: .semibold)
        static let body: SwiftUI.Font = .system(size: 17, weight: .regular)
        static let callout: SwiftUI.Font = .system(size: 16, weight: .regular)
        static let subheadline: SwiftUI.Font = .system(size: 15, weight: .regular)
        static let footnote: SwiftUI.Font = .system(size: 13, weight: .regular)
        static let caption: SwiftUI.Font = .system(size: 12, weight: .regular)
        static let caption2: SwiftUI.Font = .system(size: 11, weight: .regular)
        static let micro: SwiftUI.Font = .system(size: 10, weight: .regular)
        static let nano: SwiftUI.Font = .system(size: 9, weight: .regular)
        static let pico: SwiftUI.Font = .system(size: 8, weight: .regular)

        // MARK: - Display (hero/splash icons and numbers)
        static let displayXL: SwiftUI.Font = .system(size: 80, weight: .bold)
        static let displayLarge: SwiftUI.Font = .system(size: 72, weight: .bold)
        static let display: SwiftUI.Font = .system(size: 64, weight: .bold)
        static let displayMedium: SwiftUI.Font = .system(size: 56, weight: .bold)
        static let displaySmall: SwiftUI.Font = .system(size: 48, weight: .bold)
        static let displayXS: SwiftUI.Font = .system(size: 44, weight: .bold)
        static let displayXXS: SwiftUI.Font = .system(size: 40, weight: .bold)

        // MARK: - Icon (SF Symbol sizing)
        static let iconXL: SwiftUI.Font = .system(size: 36)
        static let iconLarge: SwiftUI.Font = .system(size: 28)
        static let iconMedium: SwiftUI.Font = .system(size: 24)
        static let iconDefault: SwiftUI.Font = .system(size: 22)
        static let iconSmall: SwiftUI.Font = .system(size: 18)
        static let iconXS: SwiftUI.Font = .system(size: 14)
        static let iconXXS: SwiftUI.Font = .system(size: 10)

        // MARK: - Rounded (game scores, XP, level badges)
        static let roundedHero: SwiftUI.Font = .system(size: 56, weight: .black, design: .rounded)
        static let roundedXL: SwiftUI.Font = .system(size: 44, weight: .bold, design: .rounded)
        static let roundedLarge: SwiftUI.Font = .system(size: 40, weight: .bold, design: .rounded)
        static let roundedTitle: SwiftUI.Font = .system(size: 36, weight: .bold, design: .rounded)
        static let roundedHeadline: SwiftUI.Font = .system(size: 34, weight: .black, design: .rounded)
        static let roundedTitle2: SwiftUI.Font = .system(size: 32, weight: .black, design: .rounded)
        static let roundedBrand: SwiftUI.Font = .system(size: 30, weight: .black, design: .rounded)
        static let roundedBody: SwiftUI.Font = .system(size: 28, weight: .bold, design: .rounded)
        static let roundedCallout: SwiftUI.Font = .system(size: 24, weight: .bold, design: .rounded)
        static let roundedSubheadline: SwiftUI.Font = .system(size: 22, weight: .black, design: .rounded)
        static let roundedSmall: SwiftUI.Font = .system(size: 20, weight: .black, design: .rounded)
        static let roundedFootnote: SwiftUI.Font = .system(size: 17, weight: .black, design: .rounded)
        static let roundedCaption: SwiftUI.Font = .system(size: 16, weight: .black, design: .rounded)
        static let roundedCaption2: SwiftUI.Font = .system(size: 14, weight: .black, design: .rounded)
        static let roundedMicro: SwiftUI.Font = .system(size: 13, weight: .black, design: .rounded)
        static let roundedMicro2: SwiftUI.Font = .system(size: 13, weight: .bold, design: .rounded)
        static let roundedNano: SwiftUI.Font = .system(size: 11, weight: .black, design: .rounded)
        static let roundedPico: SwiftUI.Font = .system(size: 10, weight: .bold, design: .rounded)

        // MARK: - Monospaced (timers, codes, grids)
        static let monoLarge: SwiftUI.Font = .system(size: 44, weight: .bold, design: .monospaced)
        static let monoMedium: SwiftUI.Font = .system(size: 40, weight: .bold, design: .monospaced)
        static let monoTitle: SwiftUI.Font = .system(size: 22, weight: .semibold, design: .monospaced)
        static let monoBody: SwiftUI.Font = .system(size: 20, weight: .bold, design: .monospaced)
        static let monoSmall: SwiftUI.Font = .system(size: 18, weight: .semibold, design: .monospaced)
        static let monoCaption: SwiftUI.Font = .system(size: 14, weight: .medium, design: .monospaced)
        static let monoCaption2: SwiftUI.Font = .system(size: 13, weight: .bold, design: .monospaced)

        // MARK: - Serif (editorial, Wikipedia)
        static let serifBody: SwiftUI.Font = .system(size: 20, weight: .bold, design: .serif)

        // MARK: - Factory (dynamic sizing)
        static func system(size: CGFloat, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: size, weight: weight)
        }

        static func system(size: CGFloat, weight: SwiftUI.Font.Weight = .regular, design: SwiftUI.Font.Design) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: design)
        }
    }
}
