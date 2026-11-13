import SwiftUI
import UIKit

public extension DesignSystem {
    enum Font {
        // MARK: - Standard Scale (Dynamic Type)
        public static let largeTitle: SwiftUI.Font = .largeTitle.weight(.bold)
        public static let title: SwiftUI.Font = .title.weight(.bold)
        public static let title2: SwiftUI.Font = .title2.weight(.semibold)
        public static let title3: SwiftUI.Font = .title3.weight(.semibold)
        public static let headline: SwiftUI.Font = .headline
        public static let body: SwiftUI.Font = .body
        public static let callout: SwiftUI.Font = .callout
        public static let subheadline: SwiftUI.Font = .subheadline
        public static let footnote: SwiftUI.Font = .footnote
        public static let caption: SwiftUI.Font = .caption
        public static let caption2: SwiftUI.Font = .caption2
        // Smaller than caption2, still scaled with Text Size from caption2's metrics.
        public static var micro: SwiftUI.Font { scaled(10, relativeTo: .caption2) }
        public static var nano: SwiftUI.Font { scaled(9, relativeTo: .caption2) }
        public static var pico: SwiftUI.Font { scaled(8, relativeTo: .caption2) }

        // MARK: - Display (hero/splash — intentionally fixed for decorative scores/numbers)
        public static let displayXL: SwiftUI.Font = .system(size: 80, weight: .bold)
        public static let displayLarge: SwiftUI.Font = .system(size: 72, weight: .bold)
        public static let display: SwiftUI.Font = .system(size: 64, weight: .bold)
        public static let displayMedium: SwiftUI.Font = .system(size: 56, weight: .bold)
        public static let displaySmall: SwiftUI.Font = .system(size: 48, weight: .bold)
        public static let displayXS: SwiftUI.Font = .system(size: 44, weight: .bold)
        public static let displayXXS: SwiftUI.Font = .system(size: 40, weight: .bold)

        // MARK: - Icon (SF Symbol sizing — scaled with Text Size so icons keep pace with the text beside them)
        public static var iconXL: SwiftUI.Font { scaled(36) }
        public static var iconLarge: SwiftUI.Font { scaled(28) }
        public static var iconMedium: SwiftUI.Font { scaled(24) }
        public static var iconDefault: SwiftUI.Font { scaled(22) }
        public static var iconSmall: SwiftUI.Font { scaled(18) }
        public static var iconXS: SwiftUI.Font { scaled(14) }
        public static var iconXXS: SwiftUI.Font { scaled(10) }

        // MARK: - Rounded (game scores, XP, level badges)
        public static let roundedHero: SwiftUI.Font = .system(size: 56, weight: .black, design: .rounded)
        public static let roundedXL: SwiftUI.Font = .system(size: 44, weight: .bold, design: .rounded)
        public static let roundedLarge: SwiftUI.Font = .system(size: 40, weight: .bold, design: .rounded)
        public static let roundedTitle: SwiftUI.Font = .system(size: 36, weight: .bold, design: .rounded)
        public static let roundedHeadline: SwiftUI.Font = .system(.largeTitle, design: .rounded, weight: .black)
        public static let roundedTitle2: SwiftUI.Font = .system(size: 32, weight: .black, design: .rounded)
        public static let roundedBrand: SwiftUI.Font = .system(size: 30, weight: .black, design: .rounded)
        public static let roundedBody: SwiftUI.Font = .system(.title, design: .rounded, weight: .bold)
        public static let roundedCallout: SwiftUI.Font = .system(.title2, design: .rounded, weight: .bold)
        public static let roundedSubheadline: SwiftUI.Font = .system(.title2, design: .rounded, weight: .black)
        public static let roundedSmall: SwiftUI.Font = .system(.title3, design: .rounded, weight: .black)
        public static let roundedFootnote: SwiftUI.Font = .system(.headline, design: .rounded, weight: .black)
        public static let roundedCaption: SwiftUI.Font = .system(.callout, design: .rounded, weight: .black)
        public static let roundedCaption2: SwiftUI.Font = .system(.footnote, design: .rounded, weight: .black)
        public static let roundedMicro: SwiftUI.Font = .system(.footnote, design: .rounded, weight: .black)
        public static let roundedMicro2: SwiftUI.Font = .system(.footnote, design: .rounded, weight: .bold)
        public static let roundedNano: SwiftUI.Font = .system(.caption2, design: .rounded, weight: .black)
        public static let roundedPico: SwiftUI.Font = .system(size: 10, weight: .bold, design: .rounded)

        // MARK: - Monospaced (timers, codes, grids)
        public static let monoLarge: SwiftUI.Font = .system(size: 44, weight: .bold, design: .monospaced)
        public static let monoMedium: SwiftUI.Font = .system(size: 40, weight: .bold, design: .monospaced)
        public static let monoTitle: SwiftUI.Font = .title3.monospacedDigit().weight(.semibold)
        public static let monoBody: SwiftUI.Font = .title3.monospacedDigit().weight(.bold)
        public static let monoSmall: SwiftUI.Font = .headline.monospacedDigit().weight(.semibold)
        public static let monoCaption: SwiftUI.Font = .footnote.monospacedDigit().weight(.medium)
        public static let monoCaption2: SwiftUI.Font = .footnote.monospacedDigit().weight(.bold)

        // MARK: - Serif (editorial, Wikipedia)
        public static let serifBody: SwiftUI.Font = .system(.title3, design: .serif, weight: .bold)

        // MARK: - Factory (escape hatch for one-off sizing)
        public static func system(size: CGFloat, weight: SwiftUI.Font.Weight = .regular) -> SwiftUI.Font {
            .system(size: size, weight: weight)
        }

        public static func system(
            size: CGFloat,
            weight: SwiftUI.Font.Weight = .regular,
            design: SwiftUI.Font.Design
        ) -> SwiftUI.Font {
            .system(size: size, weight: weight, design: design)
        }

        public static func textStyle(
            _ style: SwiftUI.Font.TextStyle,
            design: SwiftUI.Font.Design = .default,
            weight: SwiftUI.Font.Weight = .regular
        ) -> SwiftUI.Font {
            .system(style, design: design, weight: weight)
        }

        // MARK: - Scaling
        private static func scaled(_ size: CGFloat, relativeTo style: UIFont.TextStyle = .body) -> SwiftUI.Font {
            .system(size: UIFontMetrics(forTextStyle: style).scaledValue(for: size))
        }
    }
}
