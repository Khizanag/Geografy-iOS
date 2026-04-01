import Foundation

public struct CountryNeighbors: Sendable {
    /// Maps ISO 3166-1 alpha-2 country code to its land-border neighbors.
    /// Empty array means the country is an island nation with no land neighbors.
    public static let data: [String: [String]] = [
        // A
        "AF": ["CN", "IR", "PK", "TJ", "TM", "UZ"],
        "AL": ["GR", "ME", "MK", "RS"],
        "DZ": ["LY", "MA", "ML", "MR", "NE", "TN"],
        "AD": ["FR", "ES"],
        "AO": ["CD", "CG", "NA", "ZM"],
        "AR": ["BO", "BR", "CL", "PY", "UY"],
        "AM": ["AZ", "GE", "IR", "TR"],
        "AT": ["CZ", "DE", "HU", "IT", "LI", "SK", "SI", "CH"],
        "AZ": ["AM", "GE", "IR", "RU", "TR"],

        // B
        "BD": ["IN", "MM"],
        "BY": ["LV", "LT", "PL", "RU", "UA"],
        "BE": ["FR", "DE", "LU", "NL"],
        "BZ": ["GT", "MX"],
        "BJ": ["BF", "GH", "NE", "NG", "TG"],
        "BT": ["CN", "IN"],
        "BO": ["AR", "BR", "CL", "PY", "PE"],
        "BA": ["HR", "ME", "RS"],
        "BW": ["NA", "ZA", "ZM", "ZW"],
        "BR": ["AR", "BO", "CO", "GY", "PY", "PE", "SR", "UY", "VE"],
        "BN": ["MY"],
        "BG": ["GR", "MK", "RO", "RS", "TR"],
        "BF": ["BJ", "GH", "CI", "ML", "NE", "TG"],
        "BI": ["CD", "RW", "TZ"],

        // C
        "KH": ["LA", "TH", "VN"],
        "CM": ["CF", "TD", "CG", "GQ", "GA", "NG"],
        "CA": ["US"],
        "CF": ["CM", "TD", "CD", "CG", "SS", "SD"],
        "TD": ["CM", "CF", "LY", "NE", "NG", "SD"],
        "CL": ["AR", "BO", "PE"],
        "CN": ["AF", "BT", "IN", "KZ", "KP", "KG", "LA", "MN", "MM", "NP", "PK", "RU", "TJ", "VN"],
        "CO": ["BR", "EC", "PA", "PE", "VE"],
        "CD": ["CF", "CG", "BI", "RW", "SS", "TZ", "UG", "ZM"],
        "CG": ["CM", "CF", "CD", "GA"],
        "CR": ["NI", "PA"],
        "CI": ["BF", "GH", "GN", "LR", "ML"],
        "HR": ["BA", "HU", "ME", "RS", "SI"],

        // D
        "DK": ["DE"],
        "DJ": ["ER", "ET", "SO"],

        // E
        "EC": ["CO", "PE"],
        "EG": ["IL", "LY", "SD"],
        "SV": ["GT", "HN"],
        "GQ": ["CM", "GA"],
        "ER": ["DJ", "ET", "SD"],
        "EE": ["LV", "RU"],
        "ET": ["DJ", "ER", "KE", "SO", "SS", "SD"],

        // F
        "FI": ["EE", "NO", "RU", "SE"],
        "FR": ["AD", "BE", "DE", "IT", "LU", "MC", "ES", "CH"],

        // G
        "GA": ["CM", "CG", "GQ"],
        "GM": ["SN"],
        "GE": ["AM", "AZ", "RU", "TR"],
        "DE": ["AT", "BE", "CZ", "DK", "FR", "LU", "NL", "PL", "CH"],
        "GH": ["BF", "CI", "TG"],
        "GR": ["AL", "BG", "MK", "TR"],
        "GT": ["BZ", "SV", "HN", "MX"],
        "GN": ["CI", "GW", "LR", "ML", "SN", "SL"],
        "GW": ["GN", "SN"],
        "GY": ["BR", "SR", "VE"],

        // H
        "HT": ["DO"],
        "HN": ["GT", "NI", "SV"],
        "HU": ["AT", "HR", "RO", "RS", "SK", "SI", "UA"],

        // I
        "IN": ["BD", "BT", "CN", "MM", "NP", "PK"],
        "ID": ["MY", "PG", "TL"],
        "IR": ["AF", "AM", "AZ", "IQ", "PK", "TR", "TM"],
        "IQ": ["IR", "JO", "KW", "SA", "SY", "TR"],
        "IL": ["EG", "JO", "LB", "SY"],
        "IT": ["AT", "FR", "SM", "SI", "CH", "VA"],

        // J
        "JO": ["IQ", "IL", "SA", "SY"],

        // K
        "KZ": ["CN", "KG", "RU", "TM", "UZ"],
        "KE": ["ET", "SO", "SS", "TZ", "UG"],
        "KP": ["CN", "RU", "KR"],
        "KR": ["KP"],
        "KW": ["IQ", "SA"],
        "KG": ["CN", "KZ", "TJ", "UZ"],

        // L
        "LA": ["KH", "CN", "MM", "TH", "VN"],
        "LV": ["BY", "EE", "LT", "RU"],
        "LB": ["IL", "SY"],
        "LS": ["ZA"],
        "LR": ["CI", "GN", "SL"],
        "LY": ["DZ", "EG", "NE", "SD", "TN"],
        "LI": ["AT", "CH"],
        "LT": ["BY", "LV", "PL", "RU"],
        "LU": ["BE", "DE", "FR"],

        // M
        "MK": ["AL", "BG", "GR", "RS"],
        "MW": ["MZ", "TZ", "ZM"],
        "MY": ["BN", "ID", "TH"],
        "ML": ["DZ", "BF", "GN", "CI", "MR", "NE", "SN"],
        "MR": ["DZ", "ML", "SN"],
        "MX": ["BZ", "GT", "US"],
        "MD": ["RO", "UA"],
        "MC": ["FR"],
        "MN": ["CN", "RU"],
        "ME": ["AL", "BA", "HR", "RS"],
        "MA": ["DZ"],
        "MZ": ["MW", "ZA", "SZ", "TZ", "ZM", "ZW"],
        "MM": ["BD", "CN", "IN", "LA", "TH"],

        // N
        "NA": ["AO", "BW", "ZA", "ZM"],
        "NP": ["CN", "IN"],
        "NL": ["BE", "DE"],
        "NI": ["CR", "HN"],
        "NE": ["DZ", "BJ", "BF", "TD", "LY", "ML", "NG"],
        "NG": ["BJ", "CM", "TD", "NE"],
        "NO": ["FI", "RU", "SE"],

        // O
        "OM": ["SA", "AE", "YE"],

        // P
        "PK": ["AF", "CN", "IN", "IR"],
        "PA": ["CO", "CR"],
        "PG": ["ID"],
        "PY": ["AR", "BO", "BR"],
        "PE": ["BO", "BR", "CL", "CO", "EC"],
        "PL": ["BY", "CZ", "DE", "LT", "RU", "SK", "UA"],
        "PT": ["ES"],

        // Q
        "QA": ["SA"],

        // R
        "RO": ["BG", "HU", "MD", "RS", "UA"],
        "RU": ["AZ", "BY", "CN", "EE", "FI", "GE", "KZ", "KP", "LV", "LT", "MN", "NO", "PL", "UA"],
        "RW": ["BI", "CD", "TZ", "UG"],

        // S
        "SM": ["IT"],
        "SA": ["IQ", "JO", "KW", "OM", "QA", "AE", "YE"],
        "SN": ["GM", "GN", "GW", "ML", "MR"],
        "RS": ["AL", "BA", "BG", "HR", "HU", "MK", "ME", "RO"],
        "SL": ["GN", "LR"],
        "SK": ["AT", "CZ", "HU", "PL", "UA"],
        "SI": ["AT", "HR", "HU", "IT"],
        "SO": ["DJ", "ET", "KE"],
        "ZA": ["BW", "LS", "MZ", "NA", "SZ", "ZW"],
        "SS": ["CF", "CD", "ET", "KE", "SD", "UG"],
        "ES": ["AD", "FR", "PT"],
        "SD": ["CF", "CD", "EG", "ER", "ET", "LY", "SS"],
        "SR": ["BR", "GY"],
        "SZ": ["MZ", "ZA"],
        "SE": ["FI", "NO"],
        "CH": ["AT", "FR", "DE", "IT", "LI"],
        "SY": ["IQ", "IL", "JO", "LB", "TR"],

        // T
        "TJ": ["AF", "CN", "KG", "UZ"],
        "TZ": ["BI", "CD", "KE", "MW", "MZ", "RW", "UG", "ZM"],
        "TH": ["KH", "LA", "MY", "MM"],
        "TL": ["ID"],
        "TG": ["BJ", "BF", "GH"],
        "TN": ["DZ", "LY"],
        "TR": ["AM", "AZ", "BG", "GE", "GR", "IR", "IQ", "SY"],
        "TM": ["AF", "IR", "KZ", "UZ"],

        // U
        "UG": ["CD", "KE", "RW", "SS", "TZ"],
        "UA": ["BY", "HU", "MD", "PL", "RO", "RU", "SK"],
        "AE": ["OM", "SA"],
        "US": ["CA", "MX"],
        "UY": ["AR", "BR"],
        "UZ": ["AF", "KZ", "KG", "TJ", "TM"],

        // V
        "VA": ["IT"],
        "VE": ["BR", "CO", "GY"],
        "VN": ["KH", "CN", "LA"],

        // Y
        "YE": ["OM", "SA"],

        // Z
        "ZM": ["AO", "BW", "CD", "MW", "MZ", "NA", "TZ", "ZW"],
        "ZW": ["BW", "MZ", "ZA", "ZM"],

        // Island nations and city-states with no land borders
        "AG": [], "AW": [], "BS": [], "BH": [], "BB": [], "CV": [],
        "KM": [], "CU": [], "CY": [], "DM": [], "DO": [],
        "FJ": [], "GD": [],
        "IS": [], "JM": [], "JP": [],
        "KI": [], "MV": [], "MT": [], "MH": [],
        "MU": [], "FM": [], "NR": [], "NZ": [],
        "PW": [], "PH": [], "KN": [], "LC": [],
        "VC": [], "WS": [], "ST": [], "SG": [],
        "SB": [], "LK": [], "TW": [], "TT": [],
        "TV": [], "GB": [], "VU": [],
        "TO": [], "TK": [],
    ]

    public static func neighbors(for countryCode: String) -> [String] {
        data[countryCode] ?? []
    }

    public static func isIslandNation(countryCode: String) -> Bool {
        let neighbors = data[countryCode]
        return neighbors != nil && neighbors!.isEmpty
    }
}
