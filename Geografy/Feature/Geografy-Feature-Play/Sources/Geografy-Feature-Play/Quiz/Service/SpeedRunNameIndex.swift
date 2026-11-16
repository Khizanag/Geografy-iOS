import Foundation
import Geografy_Core_Common

/// Resolves typed Speed Run answers to country codes with one dictionary lookup per keystroke.
struct SpeedRunNameIndex: Sendable {
    // MARK: - Properties
    /// Codes in country-list order, so a name shared by two countries resolves the same way every time.
    private let codesByName: [String: [String]]

    // MARK: - Init
    init(countries: [Country]) {
        var codesByName: [String: [String]] = [:]
        for country in countries {
            let names = [Self.normalize(country.name)] + (Self.alternateNames[country.code] ?? [])
            for name in Set(names) {
                codesByName[name, default: []].append(country.code)
            }
        }
        self.codesByName = codesByName
    }
}

// MARK: - Lookup
extension SpeedRunNameIndex {
    /// Every country, in list order, whose name or alternate name equals `normalizedName`.
    func codes(named normalizedName: String) -> [String] {
        codesByName[normalizedName] ?? []
    }

    /// Lowercases and strips diacritics so "Côte d'Ivoire" and "cote d'ivoire" compare equal.
    static func normalize(_ name: String) -> String {
        name.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
    }
}

// MARK: - Alternate Names
private extension SpeedRunNameIndex {
    static let alternateNames: [String: [String]] = [
        "US": ["usa", "united states", "america", "u.s.a.", "u.s."],
        "GB": ["uk", "great britain", "england", "britain", "u.k."],
        "KP": ["north korea"],
        "KR": ["south korea"],
        "CD": ["drc", "democratic republic of congo", "congo dr", "congo drc"],
        "CG": ["republic of congo", "congo republic", "republic of the congo"],
        "CI": ["ivory coast", "cote d'ivoire", "cote divoire"],
        "MM": ["burma"],
        "CZ": ["czech republic"],
        "TL": ["east timor"],
        "FM": ["micronesia"],
        "MK": ["north macedonia", "macedonia"],
        "SS": ["south sudan"],
        "TT": ["trinidad and tobago"],
        "BO": ["bolivia"],
        "VE": ["venezuela"],
        "IR": ["iran"],
        "SY": ["syria"],
        "VN": ["vietnam"],
        "RU": ["russia"],
        "LA": ["laos"],
        "CV": ["cape verde"],
        "EH": ["western sahara"],
        "AE": ["uae", "emirates", "united arab emirates"],
        "XK": ["kosovo"],
    ]
}
