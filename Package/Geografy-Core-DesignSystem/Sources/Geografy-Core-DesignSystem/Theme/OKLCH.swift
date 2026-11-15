import Foundation

/// A color in OKLCH: lightness, chroma, and hue in Björn Ottosson's Oklab, a space built so that equal
/// distances look equally different. Map palettes are designed here, so their colors can be spaced evenly
/// by eye and their contrast measured, rather than picked one hex code at a time.
public struct OKLCH: Equatable, Sendable {
    /// 0 is black, 1 is white.
    public var lightness: Double
    /// 0 is grey; map fills sit around 0.05–0.16.
    public var chroma: Double
    /// In degrees: about 30 red, 70 orange, 105 yellow, 145 green, 230 blue, 300 purple.
    public var hue: Double

    public init(_ lightness: Double, _ chroma: Double, _ hue: Double) {
        self.lightness = lightness
        self.chroma = chroma
        self.hue = hue
    }

    /// The perceptual difference from `other`, ΔE in Oklab: about 0.02 is barely visible, 0.1 is plainly different.
    public func distance(to other: OKLCH) -> Double {
        let (l1, a1, b1) = oklab
        let (l2, a2, b2) = other.oklab
        return sqrt((l1 - l2) * (l1 - l2) + (a1 - a2) * (a1 - a2) + (b1 - b2) * (b1 - b2))
    }

    /// sRGB components from 0 to 1. Chroma is lowered until the color fits sRGB, keeping its lightness and hue.
    public var rgb: (red: Double, green: Double, blue: Double) {
        var fitted = self
        for _ in 0..<40 {
            let linear = fitted.linearRGB
            if [linear.0, linear.1, linear.2].allSatisfy({ (-0.0005...1.0005).contains($0) }) {
                return (Self.gamma(linear.0), Self.gamma(linear.1), Self.gamma(linear.2))
            }
            fitted.chroma *= 0.95
        }
        let linear = fitted.linearRGB
        return (Self.gamma(linear.0), Self.gamma(linear.1), Self.gamma(linear.2))
    }

    /// Whether the color fits sRGB without lowering its chroma.
    public var isInGamut: Bool {
        let linear = linearRGB
        return [linear.0, linear.1, linear.2].allSatisfy { (-0.0005...1.0005).contains($0) }
    }
}

// MARK: - Conversion
private extension OKLCH {
    var oklab: (Double, Double, Double) {
        let radians = hue * .pi / 180
        return (lightness, chroma * cos(radians), chroma * sin(radians))
    }

    var linearRGB: (Double, Double, Double) {
        let (lightness, a, b) = oklab
        let longCone = pow(lightness + 0.3963377774 * a + 0.2158037573 * b, 3)
        let mediumCone = pow(lightness - 0.1055613458 * a - 0.0638541728 * b, 3)
        let shortCone = pow(lightness - 0.0894841775 * a - 1.2914855480 * b, 3)
        return (
            4.0767416621 * longCone - 3.3077115913 * mediumCone + 0.2309699292 * shortCone,
            -1.2684380046 * longCone + 2.6097574011 * mediumCone - 0.3413193965 * shortCone,
            -0.0041960863 * longCone - 0.7034186147 * mediumCone + 1.7076147010 * shortCone
        )
    }

    static func gamma(_ linear: Double) -> Double {
        let clamped = min(max(linear, 0), 1)
        return clamped <= 0.0031308 ? 12.92 * clamped : 1.055 * pow(clamped, 1 / 2.4) - 0.055
    }
}
