import SwiftUI

extension DesignSystem {
    enum Font {
        // MARK: - Standard Scale (Dynamic Type)
        static let largeTitle: SwiftUI.Font = .largeTitle.weight(.bold)
        static let title: SwiftUI.Font = .title.weight(.bold)
        static let title2: SwiftUI.Font = .title2.weight(.semibold)
        static let title3: SwiftUI.Font = .title3.weight(.semibold)
        static let headline: SwiftUI.Font = .headline
        static let body: SwiftUI.Font = .body
        static let callout: SwiftUI.Font = .callout
        static let subheadline: SwiftUI.Font = .subheadline
        static let footnote: SwiftUI.Font = .footnote
        static let caption: SwiftUI.Font = .caption
        static let caption2: SwiftUI.Font = .caption2
        // Intentionally fixed: decorative labels below system minimum
        static let micro: SwiftUI.Font = .system(size: 10, weight: .regular)
        static let nano: SwiftUI.Font = .system(size: 9, weight: .regular)
        static let pico: SwiftUI.Font = .system(size: 8, weight: .regular)

        // MARK: - Display (hero/splash — intentionally fixed for decorative scores/numbers)
        static let displayXL: SwiftUI.Font = .system(size: 80, weight: .bold)
        static let displayLarge: SwiftUI.Font = .system(size: 72, weight: .bold)
        static let display: SwiftUI.Font = .system(size: 64, weight: .bold)
        static let displayMedium: SwiftUI.Font = .system(size: 56, weight: .bold)
        static let displaySmall: SwiftUI.Font = .system(size: 48, weight: .bold)
        static let displayXS: SwiftUI.Font = .system(size: 44, weight: .bold)
        static let displayXXS: SwiftUI.Font = .system(size: 40, weight: .bold)

        // MARK: - Icon (SF Symbol sizing — intentionally fixed for consistent icon layouts)
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
        static let roundedHeadline: SwiftUI.Font = .system(.largeTitle, design: .rounded, weight: .black)
        static let roundedTitle2: SwiftUI.Font = .system(size: 32, weight: .black, design: .rounded)
        static let roundedBrand: SwiftUI.Font = .system(size: 30, weight: .black, design: .rounded)
        static let roundedBody: SwiftUI.Font = .system(.title, design: .rounded, weight: .bold)
        static let roundedCallout: SwiftUI.Font = .system(.title2, design: .rounded, weight: .bold)
        static let roundedSubheadline: SwiftUI.Font = .system(.title2, design: .rounded, weight: .black)
        static let roundedSmall: SwiftUI.Font = .system(.title3, design: .rounded, weight: .black)
        static let roundedFootnote: SwiftUI.Font = .system(.headline, design: .rounded, weight: .black)
        static let roundedCaption: SwiftUI.Font = .system(.callout, design: .rounded, weight: .black)
        static let roundedCaption2: SwiftUI.Font = .system(.footnote, design: .rounded, weight: .black)
        static let roundedMicro: SwiftUI.Font = .system(.footnote, design: .rounded, weight: .black)
        static let roundedMicro2: SwiftUI.Font = .system(.footnote, design: .rounded, weight: .bold)
        static let roundedNano: SwiftUI.Font = .system(.caption2, design: .rounded, weight: .black)
        static let roundedPico: SwiftUI.Font = .system(size: 10, weight: .bold, design: .rounded)

        // MARK: - Monospaced (timers, codes, grids)
        static let monoLarge: SwiftUI.Font = .system(size: 44, weight: .bold, design: .monospaced)
        static let monoMedium: SwiftUI.Font = .system(size: 40, weight: .bold, design: .monospaced)
        static let monoTitle: SwiftUI.Font = .title3.monospacedDigit().weight(.semibold)
        static let monoBody: SwiftUI.Font = .title3.monospacedDigit().weight(.bold)
        static let monoSmall: SwiftUI.Font = .headline.monospacedDigit().weight(.semibold)
        static let monoCaption: SwiftUI.Font = .footnote.monospacedDigit().weight(.medium)
        static let monoCaption2: SwiftUI.Font = .footnote.monospacedDigit().weight(.bold)

        // MARK: - Serif (editorial, Wikipedia)
        static let serifBody: SwiftUI.Font = .system(.title3, design: .serif, weight: .bold)

        // MARK: - Factory (escape hatch for one-off sizing)
        static func system(size: CGFloat, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: size, weight: weight)
        }

        static func system(size: CGFloat, weight: SwiftUI.Font.Weight = .regular, design: SwiftUI.Font.Design) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: design)
        }

        static func textStyle(
            _ style: SwiftUI.Font.TextStyle,
            design: SwiftUI.Font.Design = .default,
            weight: SwiftUI.Font.Weight = .regular
        ) -> SwiftUI.Font {
            .system(style, design: design, weight: weight)
        }
    }
}
