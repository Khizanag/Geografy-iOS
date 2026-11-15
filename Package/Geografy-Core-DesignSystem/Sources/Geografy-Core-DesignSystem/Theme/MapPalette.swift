import Geografy_Core_Common
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A set of six country fills for the maps, chosen in Settings.
///
/// Each palette is designed in OKLCH, so its six colors sit far apart by eye in both light and dark mode,
/// measured by `minimumContrast`. Six is enough for any map: `MapColoringEngine` gives neighbors different
/// colors, and four always suffice for a flat map; the spare two let it keep look-alikes apart too.
public enum MapPalette: String, CaseIterable, Identifiable, Sendable {
    /// Soft political-atlas pastels: rose, apricot, butter, mint, sky, lilac.
    case atlas
    /// Saturated, clearly separate hues for the strongest contrast.
    case vivid
    /// Muted natural tones: terracotta, sand, olive, sage, heather, slate.
    case earth
    /// Based on Okabe and Ito's palette, distinguishable with the common kinds of color blindness.
    case colorSafe
    /// One warm sand color in six steps of lightness, for a calm map where neighbors differ by shade.
    case mono

    public static let colorCount = 6
    public static let `default`: MapPalette = .atlas

    public var id: String { rawValue }

    /// The palette chosen in Settings.
    public static var current: MapPalette {
        UserDefaults.standard.string(forKey: MapPreferences.paletteKey).flatMap(MapPalette.init(rawValue:)) ?? .default
    }
}

// MARK: - Colors
public extension MapPalette {
    /// The six fills, each switching between its light and dark design with the appearance.
    var colors: [Color] {
        swatches.map { Color(light: $0.light, dark: $0.dark) }
    }

    /// How different each pair of fills looks, averaged over light and dark mode: ΔE in Oklab.
    /// `MapColoringEngine` uses it to give neighbors the most different colors available.
    var distances: [[Double]] {
        let swatches = swatches
        return swatches.map { first in
            swatches.map { second in
                (first.light.distance(to: second.light) + first.dark.distance(to: second.dark)) / 2
            }
        }
    }

    /// The least difference between any two fills, in the lighter of the two modes' worst cases.
    var minimumContrast: Double {
        let swatches = swatches
        var least = Double.infinity
        for first in swatches.indices {
            for second in swatches.indices where second > first {
                least = min(
                    least,
                    swatches[first].light.distance(to: swatches[second].light),
                    swatches[first].dark.distance(to: swatches[second].dark)
                )
            }
        }
        return least
    }

    var title: LocalizedStringKey {
        switch self {
        case .atlas: "Atlas"
        case .vivid: "Vivid"
        case .earth: "Earth"
        case .colorSafe: "Color-Blind Safe"
        case .mono: "Monochrome"
        }
    }

    var summary: LocalizedStringKey {
        switch self {
        case .atlas: "Soft pastels, like a printed political atlas."
        case .vivid: "Bold, clearly separate hues for the most contrast."
        case .earth: "Muted natural tones, easy on the eyes."
        case .colorSafe: "Hues that stay distinct with common color blindness."
        case .mono: "One warm sand color in six shades, for a calm map."
        }
    }
}

// MARK: - Design
extension MapPalette {
    struct Swatch {
        let light: OKLCH
        let dark: OKLCH
    }

    /// The sea under the countries, the Ocean color in the asset catalog, for checking that land stands out.
    static let oceanLight = OKLCH(0.870, 0.026, 250.0)
    static let oceanDark = OKLCH(0.176, 0.014, 258.4)

    /// The least difference between a fill and the sea, in either mode.
    var oceanContrast: Double {
        swatches.map { min($0.light.distance(to: Self.oceanLight), $0.dark.distance(to: Self.oceanDark)) }.min() ?? 0
    }

    /// Tuned so the closest pair stays at least about 0.07 ΔE apart in both modes; see `MapPaletteTests`.
    var swatches: [Swatch] {
        switch self {
        case .atlas:
            [
                Swatch(light: OKLCH(0.83, 0.09, 18), dark: OKLCH(0.52, 0.09, 22)),
                Swatch(light: OKLCH(0.88, 0.085, 68), dark: OKLCH(0.60, 0.09, 62)),
                Swatch(light: OKLCH(0.95, 0.10, 110), dark: OKLCH(0.70, 0.085, 105)),
                Swatch(light: OKLCH(0.85, 0.09, 155), dark: OKLCH(0.54, 0.08, 152)),
                Swatch(light: OKLCH(0.76, 0.09, 250), dark: OKLCH(0.50, 0.075, 238)),
                Swatch(light: OKLCH(0.77, 0.085, 312), dark: OKLCH(0.46, 0.085, 308)),
            ]
        case .vivid:
            [
                Swatch(light: OKLCH(0.68, 0.17, 25), dark: OKLCH(0.60, 0.16, 25)),
                Swatch(light: OKLCH(0.78, 0.15, 65), dark: OKLCH(0.70, 0.14, 65)),
                Swatch(light: OKLCH(0.88, 0.16, 105), dark: OKLCH(0.80, 0.14, 105)),
                Swatch(light: OKLCH(0.70, 0.15, 150), dark: OKLCH(0.62, 0.14, 150)),
                Swatch(light: OKLCH(0.66, 0.13, 245), dark: OKLCH(0.58, 0.12, 245)),
                Swatch(light: OKLCH(0.62, 0.15, 310), dark: OKLCH(0.55, 0.14, 310)),
            ]
        case .earth:
            [
                Swatch(light: OKLCH(0.72, 0.075, 40), dark: OKLCH(0.48, 0.075, 40)),
                Swatch(light: OKLCH(0.87, 0.07, 82), dark: OKLCH(0.64, 0.07, 82)),
                Swatch(light: OKLCH(0.78, 0.055, 122), dark: OKLCH(0.55, 0.055, 122)),
                Swatch(light: OKLCH(0.65, 0.05, 165), dark: OKLCH(0.42, 0.05, 165)),
                Swatch(light: OKLCH(0.79, 0.045, 350), dark: OKLCH(0.56, 0.05, 350)),
                Swatch(light: OKLCH(0.70, 0.045, 240), dark: OKLCH(0.46, 0.045, 240)),
            ]
        case .colorSafe:
            // Okabe and Ito's orange, sky blue, bluish green, yellow, vermilion, and reddish purple,
            // lightened for fills in light mode.
            [
                Swatch(light: OKLCH(0.80, 0.12, 70), dark: OKLCH(0.66, 0.14, 70)),
                Swatch(light: OKLCH(0.80, 0.09, 235), dark: OKLCH(0.64, 0.10, 235)),
                Swatch(light: OKLCH(0.70, 0.10, 165), dark: OKLCH(0.56, 0.11, 165)),
                Swatch(light: OKLCH(0.92, 0.13, 105), dark: OKLCH(0.78, 0.14, 105)),
                Swatch(light: OKLCH(0.70, 0.13, 40), dark: OKLCH(0.56, 0.15, 40)),
                Swatch(light: OKLCH(0.76, 0.09, 345), dark: OKLCH(0.60, 0.10, 345)),
            ]
        case .mono:
            // Warm sand, not blue, so even the palest shade stands apart from the sea.
            (0..<Self.colorCount).map { step in
                let light = OKLCH(0.95 - Double(step) * 0.072, 0.045 + Double(step) * 0.008, 80)
                let dark = OKLCH(0.32 + Double(step) * 0.07, 0.02 + Double(step) * 0.007, 80)
                return Swatch(light: light, dark: dark)
            }
        }
    }
}

// MARK: - Color
extension Color {
    /// A color that follows the appearance, built from two OKLCH designs.
    init(light: OKLCH, dark: OKLCH) {
        #if canImport(UIKit)
        let lightColor = UIColor(oklch: light)
        let darkColor = UIColor(oklch: dark)
        self.init(uiColor: UIColor { traits in traits.userInterfaceStyle == .dark ? darkColor : lightColor })
        #else
        let rgb = light.rgb
        self.init(red: rgb.red, green: rgb.green, blue: rgb.blue)
        #endif
    }
}

#if canImport(UIKit)
private extension UIColor {
    convenience init(oklch: OKLCH) {
        let rgb = oklch.rgb
        self.init(red: rgb.red, green: rgb.green, blue: rgb.blue, alpha: 1)
    }
}
#endif
