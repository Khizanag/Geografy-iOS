import Foundation

/// Travel-essentials lookup: calling code, demonym, driving side, internet TLD.
///
/// Sourced from Wikipedia country info boxes. Data covers the most-visited ~80
/// countries; remaining countries fall back to ``nil`` and the UI renders
/// "Not available" so the experience degrades gracefully.
public enum CountryTravelData {
    public enum DrivingSide: String, Codable, Sendable {
        case right
        case left
    }

    public struct Essentials: Sendable {
        public let callingCode: String?
        public let demonym: String?
        public let drivingSide: DrivingSide?
        public let internetTLD: String?

        public init(
            callingCode: String? = nil,
            demonym: String? = nil,
            drivingSide: DrivingSide? = nil,
            internetTLD: String? = nil
        ) {
            self.callingCode = callingCode
            self.demonym = demonym
            self.drivingSide = drivingSide
            self.internetTLD = internetTLD
        }
    }

    /// Static lookup. Intentionally non-exhaustive — the app shows "Not available"
    /// for entries omitted here. Add rows as data becomes available.
    public static let essentials: [String: Essentials] = [
        "AE": .init(callingCode: "+971", demonym: "Emirati", drivingSide: .right, internetTLD: ".ae"),
        "AR": .init(callingCode: "+54", demonym: "Argentine", drivingSide: .right, internetTLD: ".ar"),
        "AT": .init(callingCode: "+43", demonym: "Austrian", drivingSide: .right, internetTLD: ".at"),
        "AU": .init(callingCode: "+61", demonym: "Australian", drivingSide: .left, internetTLD: ".au"),
        "BE": .init(callingCode: "+32", demonym: "Belgian", drivingSide: .right, internetTLD: ".be"),
        "BG": .init(callingCode: "+359", demonym: "Bulgarian", drivingSide: .right, internetTLD: ".bg"),
        "BR": .init(callingCode: "+55", demonym: "Brazilian", drivingSide: .right, internetTLD: ".br"),
        "CA": .init(callingCode: "+1", demonym: "Canadian", drivingSide: .right, internetTLD: ".ca"),
        "CH": .init(callingCode: "+41", demonym: "Swiss", drivingSide: .right, internetTLD: ".ch"),
        "CL": .init(callingCode: "+56", demonym: "Chilean", drivingSide: .right, internetTLD: ".cl"),
        "CN": .init(callingCode: "+86", demonym: "Chinese", drivingSide: .right, internetTLD: ".cn"),
        "CO": .init(callingCode: "+57", demonym: "Colombian", drivingSide: .right, internetTLD: ".co"),
        "CR": .init(callingCode: "+506", demonym: "Costa Rican", drivingSide: .right, internetTLD: ".cr"),
        "CZ": .init(callingCode: "+420", demonym: "Czech", drivingSide: .right, internetTLD: ".cz"),
        "DE": .init(callingCode: "+49", demonym: "German", drivingSide: .right, internetTLD: ".de"),
        "DK": .init(callingCode: "+45", demonym: "Danish", drivingSide: .right, internetTLD: ".dk"),
        "EE": .init(callingCode: "+372", demonym: "Estonian", drivingSide: .right, internetTLD: ".ee"),
        "EG": .init(callingCode: "+20", demonym: "Egyptian", drivingSide: .right, internetTLD: ".eg"),
        "ES": .init(callingCode: "+34", demonym: "Spanish", drivingSide: .right, internetTLD: ".es"),
        "FI": .init(callingCode: "+358", demonym: "Finnish", drivingSide: .right, internetTLD: ".fi"),
        "FR": .init(callingCode: "+33", demonym: "French", drivingSide: .right, internetTLD: ".fr"),
        "GB": .init(callingCode: "+44", demonym: "British", drivingSide: .left, internetTLD: ".uk"),
        "GE": .init(callingCode: "+995", demonym: "Georgian", drivingSide: .right, internetTLD: ".ge"),
        "GR": .init(callingCode: "+30", demonym: "Greek", drivingSide: .right, internetTLD: ".gr"),
        "HK": .init(callingCode: "+852", demonym: "Hongkonger", drivingSide: .left, internetTLD: ".hk"),
        "HR": .init(callingCode: "+385", demonym: "Croatian", drivingSide: .right, internetTLD: ".hr"),
        "HU": .init(callingCode: "+36", demonym: "Hungarian", drivingSide: .right, internetTLD: ".hu"),
        "ID": .init(callingCode: "+62", demonym: "Indonesian", drivingSide: .left, internetTLD: ".id"),
        "IE": .init(callingCode: "+353", demonym: "Irish", drivingSide: .left, internetTLD: ".ie"),
        "IL": .init(callingCode: "+972", demonym: "Israeli", drivingSide: .right, internetTLD: ".il"),
        "IN": .init(callingCode: "+91", demonym: "Indian", drivingSide: .left, internetTLD: ".in"),
        "IR": .init(callingCode: "+98", demonym: "Iranian", drivingSide: .right, internetTLD: ".ir"),
        "IS": .init(callingCode: "+354", demonym: "Icelander", drivingSide: .right, internetTLD: ".is"),
        "IT": .init(callingCode: "+39", demonym: "Italian", drivingSide: .right, internetTLD: ".it"),
        "JP": .init(callingCode: "+81", demonym: "Japanese", drivingSide: .left, internetTLD: ".jp"),
        "KE": .init(callingCode: "+254", demonym: "Kenyan", drivingSide: .left, internetTLD: ".ke"),
        "KR": .init(callingCode: "+82", demonym: "Korean", drivingSide: .right, internetTLD: ".kr"),
        "KZ": .init(callingCode: "+7", demonym: "Kazakh", drivingSide: .right, internetTLD: ".kz"),
        "LT": .init(callingCode: "+370", demonym: "Lithuanian", drivingSide: .right, internetTLD: ".lt"),
        "LV": .init(callingCode: "+371", demonym: "Latvian", drivingSide: .right, internetTLD: ".lv"),
        "MA": .init(callingCode: "+212", demonym: "Moroccan", drivingSide: .right, internetTLD: ".ma"),
        "MX": .init(callingCode: "+52", demonym: "Mexican", drivingSide: .right, internetTLD: ".mx"),
        "MY": .init(callingCode: "+60", demonym: "Malaysian", drivingSide: .left, internetTLD: ".my"),
        "NG": .init(callingCode: "+234", demonym: "Nigerian", drivingSide: .right, internetTLD: ".ng"),
        "NL": .init(callingCode: "+31", demonym: "Dutch", drivingSide: .right, internetTLD: ".nl"),
        "NO": .init(callingCode: "+47", demonym: "Norwegian", drivingSide: .right, internetTLD: ".no"),
        "NZ": .init(callingCode: "+64", demonym: "New Zealander", drivingSide: .left, internetTLD: ".nz"),
        "PE": .init(callingCode: "+51", demonym: "Peruvian", drivingSide: .right, internetTLD: ".pe"),
        "PH": .init(callingCode: "+63", demonym: "Filipino", drivingSide: .right, internetTLD: ".ph"),
        "PL": .init(callingCode: "+48", demonym: "Polish", drivingSide: .right, internetTLD: ".pl"),
        "PT": .init(callingCode: "+351", demonym: "Portuguese", drivingSide: .right, internetTLD: ".pt"),
        "RO": .init(callingCode: "+40", demonym: "Romanian", drivingSide: .right, internetTLD: ".ro"),
        "RS": .init(callingCode: "+381", demonym: "Serbian", drivingSide: .right, internetTLD: ".rs"),
        "RU": .init(callingCode: "+7", demonym: "Russian", drivingSide: .right, internetTLD: ".ru"),
        "SA": .init(callingCode: "+966", demonym: "Saudi", drivingSide: .right, internetTLD: ".sa"),
        "SE": .init(callingCode: "+46", demonym: "Swedish", drivingSide: .right, internetTLD: ".se"),
        "SG": .init(callingCode: "+65", demonym: "Singaporean", drivingSide: .left, internetTLD: ".sg"),
        "SI": .init(callingCode: "+386", demonym: "Slovene", drivingSide: .right, internetTLD: ".si"),
        "SK": .init(callingCode: "+421", demonym: "Slovak", drivingSide: .right, internetTLD: ".sk"),
        "TH": .init(callingCode: "+66", demonym: "Thai", drivingSide: .left, internetTLD: ".th"),
        "TR": .init(callingCode: "+90", demonym: "Turkish", drivingSide: .right, internetTLD: ".tr"),
        "TW": .init(callingCode: "+886", demonym: "Taiwanese", drivingSide: .right, internetTLD: ".tw"),
        "UA": .init(callingCode: "+380", demonym: "Ukrainian", drivingSide: .right, internetTLD: ".ua"),
        "US": .init(callingCode: "+1", demonym: "American", drivingSide: .right, internetTLD: ".us"),
        "UY": .init(callingCode: "+598", demonym: "Uruguayan", drivingSide: .right, internetTLD: ".uy"),
        "UZ": .init(callingCode: "+998", demonym: "Uzbek", drivingSide: .right, internetTLD: ".uz"),
        "VN": .init(callingCode: "+84", demonym: "Vietnamese", drivingSide: .right, internetTLD: ".vn"),
        "ZA": .init(callingCode: "+27", demonym: "South African", drivingSide: .left, internetTLD: ".za"),
    ]

    public static func essentials(for code: String) -> Essentials? {
        essentials[code.uppercased()]
    }

    /// IANA timezone for a country, with graceful fallback.
    public static func timeZoneIdentifier(for code: String) -> String? {
        CountryTimeZoneData.timeZoneByCountryCode[code.uppercased()]
    }

    /// Human-friendly timezone offset, derived from the IANA identifier.
    /// Returns e.g. "UTC+03:00" or `nil` when the country has no entry.
    public static func timeZoneOffsetDisplay(for code: String) -> String? {
        guard let identifier = timeZoneIdentifier(for: code),
              let zone = TimeZone(identifier: identifier) else { return nil }
        let seconds = zone.secondsFromGMT()
        let sign = seconds >= 0 ? "+" : "-"
        let absolute = abs(seconds)
        let hours = absolute / 3_600
        let minutes = (absolute % 3_600) / 60
        return String(format: "UTC%@%02d:%02d", sign, hours, minutes)
    }
}
