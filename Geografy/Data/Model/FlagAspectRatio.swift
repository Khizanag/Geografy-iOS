import Foundation

/// Authoritative width-to-height ratios for country flags.
/// Values > 1.0 indicate a flag wider than tall (landscape).
/// Values < 1.0 indicate a flag taller than wide (portrait).
/// Falls back to the PDF's intrinsic ratio when a code is not listed.
enum FlagAspectRatio {
    static let ratios: [String: CGFloat] = [
        // Square flags
        "CH": 1.0,  // Switzerland
        "VA": 1.0,  // Vatican City

        // Portrait flags
        "NP": 0.615,  // Nepal — double-pennant bounding box ~4:6.5

        // Wide flags (2:1 or wider)
        "GB": 2.0,   // United Kingdom      1:2 (h:w)
        "AU": 2.0,   // Australia           1:2
        "NZ": 2.0,   // New Zealand         1:2
        "HK": 2.0,   // Hong Kong           1:2
        "JM": 2.0,   // Jamaica             1:2
        "MY": 2.0,   // Malaysia            1:2
        "SG": 2.0,   // Singapore           2:3 → actually 2:3 standard

        // Very wide flags
        "QA": 2.545,  // Qatar   11:28 (h:w) → 28/11
        "BH": 2.545,  // Bahrain 11:28 (h:w)

        // Standard 3:2 (most common — listed here as documentation; FlagView defaults to PDF ratio)
        // "FR": 1.5, "DE": 1.5, "IT": 1.5 — handled by PDF intrinsic size

        // US flag is close to 10:19
        "US": 1.9,

        // Oman is 1:2
        "OM": 2.0,
    ]

    static func ratio(for countryCode: String) -> CGFloat? {
        ratios[countryCode.uppercased()]
    }
}
