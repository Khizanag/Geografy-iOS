import Foundation

/// Authoritative width-to-height ratios for country flags.
///
/// Values represent `width / height`:
/// - `> 1.0` → landscape (wider than tall)
/// - `= 1.0` → square
/// - `< 1.0` → portrait / non-rectangular (Nepal)
///
/// `FlagView` falls back to the PDF asset's intrinsic ratio when a code is not listed.
enum FlagAspectRatio {

    // MARK: - Lookup
    static func ratio(for countryCode: String) -> CGFloat? {
        ratios[countryCode.uppercased()]
    }

    // MARK: - Data
    static let ratios: [String: CGFloat] = {
        var map = [String: CGFloat]()

        // ── Square (1:1) ──────────────────────────────────────────────
        let square: [String] = ["CH", "VA"]
        for code in square { map[code] = 1.0 }

        // ── Non-rectangular ───────────────────────────────────────────
        // Nepal double-pennant: width ≈ 9.5 units, height ≈ 12 units
        map["NP"] = 9.5 / 12.0

        // ── 1:2 (height:width → ratio 2.0) ───────────────────────────
        let oneToTwo: [String] = [
            "AU", "BB", "BZ", "BS", "CA", "CK", "DM",
            "FJ", "GB", "GD", "GY", "JM", "KI", "LC",
            "LK", "LY", "MH", "MT", "MU", "MV", "MY",
            "NR", "NZ", "PG", "SB", "SL", "TT", "TV",
            "VC", "VU", "WS",
            // Middle East 1:2
            "AE", "JO", "KW", "OM", "PS",
        ]
        for code in oneToTwo { map[code] = 2.0 }

        // ── 2:3 (height:width → ratio 1.5, most common) ──────────────
        let twoToThree: [String] = [
            // Europe
            "AL", "AD", "AT", "BA", "BG", "BY", "CZ", "DE", "DK",
            "EE", "ES", "FI", "FR", "GE", "GR", "HR", "HU", "IE",
            "IS", "IT", "LI", "LT", "LU", "LV", "MC", "MD", "ME",
            "MK", "NL", "NO", "PL", "PT", "RO", "RS", "RU", "SE",
            "SI", "SK", "UA",
            // Americas
            "AR", "BO", "BR", "CL", "CO", "DO", "EC", "GT", "HN",
            "HT", "MX", "NI", "PA", "PE", "PY", "SV", "UY", "VE",
            // Asia / Oceania
            "AF", "AM", "AZ", "BD", "BN", "BT", "CN", "CY", "ID",
            "IL", "IN", "IQ", "IR", "JP", "KG", "KH", "KR", "KZ",
            "LA", "LB", "MM", "MN", "PH", "PK", "SA", "SG", "SY",
            "TH", "TJ", "TL", "TM", "TR", "TW", "UZ", "VN", "YE",
            // Africa
            "AO", "BF", "BI", "BJ", "BW", "CD", "CF", "CG", "CM",
            "CV", "DJ", "DZ", "EG", "ER", "ET", "GA", "GH", "GM",
            "GN", "GQ", "GW", "KE", "KM", "LS", "MA", "MG", "ML",
            "MR", "MW", "MZ", "NA", "NE", "NG", "RW", "SD", "SN",
            "SO", "SS", "ST", "TD", "TN", "TZ", "UG", "ZA", "ZM",
            "ZW",
            // Africa exception overridden below: CI, SL already in 1:2
        ]
        for code in twoToThree { map[code] = 1.5 }

        // ── 3:5 (height:width → ratio 5/3 ≈ 1.667) ──────────────────
        let threeToFive: [String] = ["BH", "CR", "CU"]
        for code in threeToFive { map[code] = 5.0 / 3.0 }

        // ── 5:8 (height:width → ratio 1.6) ───────────────────────────
        map["PW"] = 8.0 / 5.0

        // ── 10:19 (height:width → ratio 1.9) ─────────────────────────
        // Override MH and FM from 1:2 group above
        let tenToNineteen: [String] = ["US", "MH", "FM"]
        for code in tenToNineteen { map[code] = 19.0 / 10.0 }

        // ── 11:28 (height:width → ratio 28/11 ≈ 2.545) ──────────────
        map["QA"] = 28.0 / 11.0

        // ── 13:15 (height:width → ratio 15/13 ≈ 1.154) ──────────────
        map["BE"] = 15.0 / 13.0

        // ── Golden ratio (1:φ → ratio ≈ 1.618) ───────────────────────
        map["TG"] = 1.618

        // ── Ivory Coast — 2:3 (same as most African flags) ───────────
        map["CI"] = 1.5

        // ── Hong Kong — 2:3 ──────────────────────────────────────────
        map["HK"] = 1.5

        // ── KN (Saint Kitts and Nevis) — 2:3 ─────────────────────────
        map["KN"] = 1.5

        return map
    }()
}
