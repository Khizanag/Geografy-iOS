import Foundation

/// Generates progressive clues for a given country.
enum ClueGenerator {
    static func generateClues(for country: Country) -> [ExploreClue] {
        [
            continentClue(for: country),
            populationClue(for: country),
            flagColorsClue(for: country),
            capitalClue(for: country),
            bordersClue(for: country),
        ]
    }
}

// MARK: - Clue Builders

private extension ClueGenerator {
    static func continentClue(for country: Country) -> ExploreClue {
        ExploreClue(
            index: 0,
            icon: "globe.americas.fill",
            title: "Continent",
            detail: "This country is in \(country.continent.displayName)."
        )
    }

    static func populationClue(for country: Country) -> ExploreClue {
        let range = populationRange(country.population)

        return ExploreClue(
            index: 1,
            icon: "person.3.fill",
            title: "Population",
            detail: "This country has \(range)."
        )
    }

    static func flagColorsClue(for country: Country) -> ExploreClue {
        let colors = flagColors(for: country.code)

        return ExploreClue(
            index: 2,
            icon: "paintpalette.fill",
            title: "Flag Colors",
            detail: "The flag features \(colors)."
        )
    }

    static func capitalClue(for country: Country) -> ExploreClue {
        let capitalName = country.capital
        let firstLetter = capitalName.prefix(1).uppercased()

        return ExploreClue(
            index: 3,
            icon: "building.columns.fill",
            title: "Capital Hint",
            detail: "The capital starts with \"\(firstLetter)\" and has \(capitalName.count) letters."
        )
    }

    static func bordersClue(for country: Country) -> ExploreClue {
        let borderNames = borderCountryNames(for: country.code)

        let detail: String = if borderNames.isEmpty {
            "This is an island nation with no land borders."
        } else if borderNames.count <= 3 {
            "It borders: \(borderNames.joined(separator: ", "))."
        } else {
            let shown = borderNames.prefix(3)
            "It borders \(borderNames.count) countries, including \(shown.joined(separator: ", "))."
        }

        return ExploreClue(
            index: 4,
            icon: "map.fill",
            title: "Neighbors",
            detail: detail
        )
    }
}

// MARK: - Population Formatting

private extension ClueGenerator {
    static func populationRange(_ population: Int) -> String {
        switch population {
        case ..<100_000:
            "fewer than 100,000 people"
        case 100_000..<1_000_000:
            "between 100K and 1 million people"
        case 1_000_000..<5_000_000:
            "between 1 and 5 million people"
        case 5_000_000..<10_000_000:
            "between 5 and 10 million people"
        case 10_000_000..<25_000_000:
            "between 10 and 25 million people"
        case 25_000_000..<50_000_000:
            "between 25 and 50 million people"
        case 50_000_000..<100_000_000:
            "between 50 and 100 million people"
        case 100_000_000..<500_000_000:
            "between 100 and 500 million people"
        default:
            "over 500 million people"
        }
    }
}

// MARK: - Flag Colors

private extension ClueGenerator {
    static func flagColors(for countryCode: String) -> String {
        flagColorData[countryCode] ?? "multiple colors"
    }
}

// MARK: - Flag Color Data

private extension ClueGenerator {
    static let flagColorData: [String: String] = [
        // Major countries — enough for a fun game
        "AF": "black, red, and green with a white emblem",
        "AL": "red with a black double-headed eagle",
        "DZ": "green and white with a red crescent and star",
        "AD": "blue, yellow, and red vertical stripes",
        "AO": "red and black with a yellow emblem",
        "AG": "red, blue, black, white, and yellow",
        "AR": "light blue and white with a golden sun",
        "AM": "red, blue, and orange horizontal stripes",
        "AU": "blue with the Union Jack and white stars",
        "AT": "red and white horizontal stripes",
        "AZ": "blue, red, and green with a white crescent",
        "BS": "aquamarine, gold, and black",
        "BH": "red and white with a serrated edge",
        "BD": "green with a red circle",
        "BB": "blue and gold with a black trident",
        "BY": "red and green with a white ornamental pattern",
        "BE": "black, yellow, and red vertical stripes",
        "BZ": "blue with a red stripe and circular emblem",
        "BJ": "green, yellow, and red",
        "BT": "yellow and orange with a white dragon",
        "BO": "red, yellow, and green horizontal stripes",
        "BA": "blue with a yellow triangle and white stars",
        "BW": "light blue with a black and white stripe",
        "BR": "green and yellow with a blue globe",
        "BN": "yellow with black and white diagonal stripes",
        "BG": "white, green, and red horizontal stripes",
        "BF": "red and green with a yellow star",
        "BI": "red, green, and white with three stars",
        "CV": "blue with red and white stripes and yellow stars",
        "KH": "blue and red with a white temple",
        "CM": "green, red, and yellow with a star",
        "CA": "red and white with a maple leaf",
        "CF": "blue, white, green, yellow, and red",
        "TD": "blue, yellow, and red vertical stripes",
        "CL": "red, white, and blue with a white star",
        "CN": "red with yellow stars",
        "CO": "yellow, blue, and red horizontal stripes",
        "KM": "green with a white crescent and four stripes",
        "CG": "green, yellow, and red diagonal",
        "CD": "blue with a red diagonal and yellow star",
        "CR": "blue, white, and red horizontal stripes",
        "CI": "orange, white, and green vertical stripes",
        "HR": "red, white, and blue with a checkered coat of arms",
        "CU": "blue and white stripes with a red triangle",
        "CY": "white with a copper-colored island shape",
        "CZ": "white, red, and blue with a blue triangle",
        "DK": "red with a white Scandinavian cross",
        "DJ": "light blue, green, and white with a red star",
        "DM": "green with a cross of yellow, black, and white",
        "DO": "red and blue quarters with a white cross",
        "EC": "yellow, blue, and red with a coat of arms",
        "EG": "red, white, and black with a golden eagle",
        "SV": "blue and white with a coat of arms",
        "GQ": "green, white, red, and blue with a coat of arms",
        "ER": "blue, green, and red with a yellow olive branch",
        "EE": "blue, black, and white horizontal stripes",
        "SZ": "blue, yellow, red with a black and white shield",
        "ET": "green, yellow, and red with a blue circle",
        "FJ": "light blue with the Union Jack and a shield",
        "FI": "white with a blue Scandinavian cross",
        "FR": "blue, white, and red vertical stripes",
        "GA": "green, yellow, and blue horizontal stripes",
        "GM": "red, blue, and green with white stripes",
        "GE": "white with a red cross and four red crosses",
        "DE": "black, red, and gold horizontal stripes",
        "GH": "red, gold, and green with a black star",
        "GR": "blue and white stripes with a cross",
        "GD": "red, yellow, and green with nutmeg symbols",
        "GT": "blue and white with a coat of arms",
        "GN": "red, yellow, and green vertical stripes",
        "GW": "red, yellow, and green with a black star",
        "GY": "green with a red and black arrowhead",
        "HT": "blue and red with a white coat of arms",
        "HN": "blue and white with five blue stars",
        "HU": "red, white, and green horizontal stripes",
        "IS": "blue with a red and white Scandinavian cross",
        "IN": "saffron, white, and green with a blue wheel",
        "ID": "red and white horizontal stripes",
        "IR": "green, white, and red with a red emblem",
        "IQ": "red, white, and black with green Arabic text",
        "IE": "green, white, and orange vertical stripes",
        "IL": "white with blue stripes and a Star of David",
        "IT": "green, white, and red vertical stripes",
        "JM": "green, black, and gold with a diagonal cross",
        "JP": "white with a red circle",
        "JO": "black, white, and green with a red triangle",
        "KZ": "turquoise with a golden sun and eagle",
        "KE": "black, red, and green with a Maasai shield",
        "KI": "red and blue with a yellow frigate bird",
        "KP": "blue, red, and white with a red star",
        "KR": "white with a red and blue circle and trigrams",
        "KW": "green, white, and red with a black trapezoid",
        "KG": "red with a golden sun and yurt symbol",
        "LA": "red, blue, and white with a white circle",
        "LV": "maroon and white horizontal stripes",
        "LB": "red and white with a green cedar tree",
        "LS": "blue, white, and green with a black hat",
        "LR": "red and white stripes with a blue canton",
        "LY": "red, black, and green with a white crescent",
        "LI": "blue and red with a golden crown",
        "LT": "yellow, green, and red horizontal stripes",
        "LU": "red, white, and blue horizontal stripes",
        "MG": "white, red, and green",
        "MW": "black, red, and green with a rising sun",
        "MY": "red and white stripes with a blue canton",
        "MV": "red with a green rectangle and white crescent",
        "ML": "green, gold, and red vertical stripes",
        "MT": "white and red with a grey cross",
        "MH": "blue with white and orange diagonal stripes",
        "MR": "green with a gold crescent and star",
        "MU": "red, blue, yellow, and green horizontal stripes",
        "MX": "green, white, and red with an eagle emblem",
        "FM": "blue with four white stars",
        "MD": "blue, yellow, and red with a coat of arms",
        "MC": "red and white horizontal stripes",
        "MN": "red and blue with a golden soyombo symbol",
        "ME": "red with a golden coat of arms",
        "MA": "red with a green pentagram star",
        "MZ": "green, black, yellow, white, and red",
        "MM": "yellow, green, and red with a white star",
        "NA": "blue, red, and green diagonal with a sun",
        "NR": "blue with a yellow stripe and white star",
        "NP": "crimson red with blue borders — unique shape",
        "NL": "red, white, and blue horizontal stripes",
        "NZ": "blue with the Union Jack and red stars",
        "NI": "blue and white with a coat of arms",
        "NE": "orange, white, and green with an orange circle",
        "NG": "green and white vertical stripes",
        "MK": "red with a golden sun and rays",
        "NO": "red with a blue and white Scandinavian cross",
        "OM": "red, white, and green with a national emblem",
        "PK": "green and white with a crescent and star",
        "PW": "blue with a golden circle",
        "PS": "black, white, green with a red triangle",
        "PA": "white, blue, and red quarters with stars",
        "PG": "red and black diagonal with stars and a bird",
        "PY": "red, white, and blue with different emblems",
        "PE": "red and white vertical stripes",
        "PH": "blue, red, and white with a golden sun",
        "PL": "white and red horizontal stripes",
        "PT": "green and red with a coat of arms",
        "QA": "maroon and white with a serrated edge",
        "RO": "blue, yellow, and red vertical stripes",
        "RU": "white, blue, and red horizontal stripes",
        "RW": "blue, yellow, and green with a golden sun",
        "KN": "green, red, and black diagonal with white stars",
        "LC": "blue with a golden and black triangle",
        "VC": "blue, yellow, and green with green diamonds",
        "WS": "red and blue with white stars",
        "SM": "white and light blue with a coat of arms",
        "ST": "green, yellow, and black with two stars",
        "SA": "green with white Arabic text and a sword",
        "SN": "green, yellow, and red with a green star",
        "RS": "red, blue, and white with a coat of arms",
        "SC": "blue, yellow, red, white, and green rays",
        "SL": "green, white, and blue horizontal stripes",
        "SG": "red and white with a crescent and stars",
        "SK": "white, blue, and red with a coat of arms",
        "SI": "white, blue, and red with a coat of arms",
        "SB": "blue and green diagonal with yellow stripe",
        "SO": "light blue with a white star",
        "ZA": "green, black, gold, white, red, and blue — Y shape",
        "SS": "black, red, green with white stripes and a blue triangle",
        "ES": "red and yellow with a coat of arms",
        "LK": "maroon and orange with a golden lion",
        "SD": "red, white, and black with a green triangle",
        "SR": "green, white, and red with a yellow star",
        "SE": "blue with a golden Scandinavian cross",
        "CH": "red with a white cross",
        "SY": "red, white, and black with two green stars",
        "TW": "red with a blue canton and white sun",
        "TJ": "red, white, and green with a golden crown",
        "TZ": "green, blue, black, and yellow diagonal",
        "TH": "red, white, and blue horizontal stripes",
        "TL": "red with black and yellow triangles and a star",
        "TG": "green and yellow stripes with a red canton",
        "TO": "red with a white canton containing a red cross",
        "TT": "red with a black and white diagonal stripe",
        "TN": "red with a white circle, crescent, and star",
        "TR": "red with a white crescent and star",
        "TM": "green with a vertical carpet stripe and crescent",
        "TV": "light blue with the Union Jack and yellow stars",
        "UG": "black, yellow, red stripes with a grey crane",
        "UA": "blue and yellow horizontal stripes",
        "AE": "green, white, black with a red vertical band",
        "GB": "red, white, and blue Union Jack",
        "US": "red and white stripes with white stars on blue",
        "UY": "white and blue stripes with a golden sun",
        "UZ": "blue, white, green with red stripes and a crescent",
        "VU": "red and green with black triangle and yellow Y",
        "VE": "yellow, blue, and red with white stars",
        "VN": "red with a yellow star",
        "YE": "red, white, and black horizontal stripes",
        "ZM": "green with an eagle and red, black, orange stripes",
        "ZW": "green, yellow, red, black with a white triangle",
        "EH": "black, white, and green with a red triangle",
        "GL": "white and red with a counterchanged circle",
        "XK": "blue with a golden map and six white stars",
        "VA": "yellow and white with the papal coat of arms",
    ]
}

// MARK: - Border Data

private extension ClueGenerator {
    static func borderCountryNames(
        for countryCode: String
    ) -> [String] {
        guard let codes = borderData[countryCode] else {
            return []
        }
        return codes
    }

    static let borderData: [String: [String]] = [
        "AF": ["Iran", "Pakistan", "Turkmenistan", "Uzbekistan", "Tajikistan", "China"],
        "AL": ["Montenegro", "Kosovo", "North Macedonia", "Greece"],
        "DZ": ["Morocco", "Tunisia", "Libya", "Niger", "Mali", "Mauritania"],
        "AD": ["France", "Spain"],
        "AO": ["Namibia", "Zambia", "Democratic Republic of the Congo", "Republic of the Congo"],
        "AR": ["Chile", "Bolivia", "Paraguay", "Brazil", "Uruguay"],
        "AM": ["Turkey", "Georgia", "Azerbaijan", "Iran"],
        "AT": ["Germany", "Czech Republic", "Slovakia", "Hungary", "Slovenia", "Italy", "Switzerland", "Liechtenstein"],
        "AZ": ["Russia", "Georgia", "Armenia", "Iran", "Turkey"],
        "BD": ["India", "Myanmar"],
        "BY": ["Russia", "Ukraine", "Poland", "Lithuania", "Latvia"],
        "BE": ["France", "Luxembourg", "Germany", "Netherlands"],
        "BZ": ["Mexico", "Guatemala"],
        "BJ": ["Togo", "Burkina Faso", "Niger", "Nigeria"],
        "BT": ["India", "China"],
        "BO": ["Brazil", "Paraguay", "Argentina", "Chile", "Peru"],
        "BA": ["Serbia", "Croatia", "Montenegro"],
        "BW": ["Namibia", "South Africa", "Zimbabwe", "Zambia"],
        "BR": [
            "Uruguay", "Argentina", "Paraguay", "Bolivia", "Peru",
            "Colombia", "Venezuela", "Guyana", "Suriname", "French Guiana",
        ],
        "BN": ["Malaysia"],
        "BG": ["Romania", "Serbia", "North Macedonia", "Greece", "Turkey"],
        "BF": ["Mali", "Niger", "Benin", "Togo", "Ghana", "Ivory Coast"],
        "BI": ["Democratic Republic of the Congo", "Rwanda", "Tanzania"],
        "KH": ["Thailand", "Laos", "Vietnam"],
        "CM": ["Nigeria", "Chad", "Central African Republic", "Republic of the Congo", "Gabon", "Equatorial Guinea"],
        "CA": ["United States"],
        "CF": ["Chad", "Sudan", "South Sudan", "Democratic Republic of the Congo", "Republic of the Congo", "Cameroon"],
        "TD": ["Libya", "Niger", "Nigeria", "Cameroon", "Central African Republic", "Sudan"],
        "CL": ["Peru", "Bolivia", "Argentina"],
        "CN": [
            "Mongolia", "Russia", "North Korea", "Vietnam", "Laos",
            "Myanmar", "India", "Bhutan", "Nepal", "Pakistan",
            "Afghanistan", "Tajikistan", "Kyrgyzstan", "Kazakhstan",
        ],
        "CO": ["Venezuela", "Brazil", "Peru", "Ecuador", "Panama"],
        "CG": ["Gabon", "Cameroon", "Central African Republic", "Democratic Republic of the Congo", "Angola"],
        "CD": [
            "Republic of the Congo", "Central African Republic",
            "South Sudan", "Uganda", "Rwanda", "Burundi",
            "Tanzania", "Zambia", "Angola",
        ],
        "CR": ["Nicaragua", "Panama"],
        "CI": ["Liberia", "Guinea", "Mali", "Burkina Faso", "Ghana"],
        "HR": ["Slovenia", "Hungary", "Serbia", "Bosnia and Herzegovina", "Montenegro"],
        "CU": [],
        "CY": [],
        "CZ": ["Germany", "Poland", "Slovakia", "Austria"],
        "DK": ["Germany"],
        "DJ": ["Eritrea", "Ethiopia", "Somalia"],
        "DM": [],
        "DO": ["Haiti"],
        "EC": ["Colombia", "Peru"],
        "EG": ["Libya", "Sudan", "Israel", "Palestine"],
        "SV": ["Guatemala", "Honduras"],
        "GQ": ["Cameroon", "Gabon"],
        "ER": ["Sudan", "Ethiopia", "Djibouti"],
        "EE": ["Russia", "Latvia"],
        "SZ": ["South Africa", "Mozambique"],
        "ET": ["Eritrea", "Djibouti", "Somalia", "Kenya", "South Sudan", "Sudan"],
        "FI": ["Sweden", "Norway", "Russia"],
        "FR": ["Belgium", "Luxembourg", "Germany", "Switzerland", "Italy", "Spain", "Andorra", "Monaco"],
        "GA": ["Equatorial Guinea", "Cameroon", "Republic of the Congo"],
        "GM": ["Senegal"],
        "GE": ["Russia", "Turkey", "Armenia", "Azerbaijan"],
        "DE": [
            "Denmark", "Poland", "Czech Republic", "Austria",
            "Switzerland", "France", "Luxembourg", "Belgium", "Netherlands",
        ],
        "GH": ["Ivory Coast", "Burkina Faso", "Togo"],
        "GR": ["Albania", "North Macedonia", "Bulgaria", "Turkey"],
        "GT": ["Mexico", "Belize", "Honduras", "El Salvador"],
        "GN": ["Guinea-Bissau", "Senegal", "Mali", "Ivory Coast", "Liberia", "Sierra Leone"],
        "GW": ["Senegal", "Guinea"],
        "GY": ["Venezuela", "Brazil", "Suriname"],
        "HT": ["Dominican Republic"],
        "HN": ["Guatemala", "El Salvador", "Nicaragua"],
        "HU": ["Austria", "Slovakia", "Ukraine", "Romania", "Serbia", "Croatia", "Slovenia"],
        "IN": ["Pakistan", "China", "Nepal", "Bhutan", "Bangladesh", "Myanmar"],
        "ID": ["Malaysia", "Papua New Guinea", "East Timor"],
        "IR": ["Iraq", "Turkey", "Armenia", "Azerbaijan", "Turkmenistan", "Afghanistan", "Pakistan"],
        "IQ": ["Turkey", "Iran", "Kuwait", "Saudi Arabia", "Jordan", "Syria"],
        "IE": ["United Kingdom"],
        "IL": ["Lebanon", "Syria", "Jordan", "Egypt", "Palestine"],
        "IT": ["France", "Switzerland", "Austria", "Slovenia", "San Marino", "Vatican City"],
        "JM": [],
        "JP": [],
        "JO": ["Syria", "Iraq", "Saudi Arabia", "Israel", "Palestine"],
        "KZ": ["Russia", "China", "Kyrgyzstan", "Uzbekistan", "Turkmenistan"],
        "KE": ["Ethiopia", "Somalia", "Tanzania", "Uganda", "South Sudan"],
        "KP": ["China", "South Korea", "Russia"],
        "KR": ["North Korea"],
        "KW": ["Iraq", "Saudi Arabia"],
        "KG": ["China", "Kazakhstan", "Uzbekistan", "Tajikistan"],
        "LA": ["Myanmar", "China", "Vietnam", "Cambodia", "Thailand"],
        "LV": ["Estonia", "Lithuania", "Russia", "Belarus"],
        "LB": ["Syria", "Israel"],
        "LS": ["South Africa"],
        "LR": ["Guinea", "Ivory Coast", "Sierra Leone"],
        "LY": ["Tunisia", "Algeria", "Niger", "Chad", "Sudan", "Egypt"],
        "LI": ["Switzerland", "Austria"],
        "LT": ["Latvia", "Belarus", "Poland", "Russia"],
        "LU": ["Belgium", "Germany", "France"],
        "MG": [],
        "MW": ["Mozambique", "Tanzania", "Zambia"],
        "MY": ["Thailand", "Indonesia", "Brunei"],
        "MV": [],
        "ML": ["Algeria", "Niger", "Burkina Faso", "Ivory Coast", "Guinea", "Senegal", "Mauritania"],
        "MT": [],
        "MR": ["Morocco", "Algeria", "Mali", "Senegal"],
        "MX": ["United States", "Guatemala", "Belize"],
        "MD": ["Romania", "Ukraine"],
        "MC": ["France"],
        "MN": ["Russia", "China"],
        "ME": ["Bosnia and Herzegovina", "Serbia", "Kosovo", "Albania", "Croatia"],
        "MA": ["Algeria", "Mauritania"],
        "MZ": ["South Africa", "Eswatini", "Zimbabwe", "Zambia", "Malawi", "Tanzania"],
        "MM": ["Bangladesh", "India", "China", "Laos", "Thailand"],
        "NA": ["Angola", "Zambia", "Botswana", "South Africa"],
        "NP": ["China", "India"],
        "NL": ["Belgium", "Germany"],
        "NZ": [],
        "NI": ["Honduras", "Costa Rica"],
        "NE": ["Algeria", "Libya", "Chad", "Nigeria", "Benin", "Burkina Faso", "Mali"],
        "NG": ["Benin", "Niger", "Chad", "Cameroon"],
        "MK": ["Serbia", "Kosovo", "Albania", "Greece", "Bulgaria"],
        "NO": ["Sweden", "Finland", "Russia"],
        "OM": ["United Arab Emirates", "Saudi Arabia", "Yemen"],
        "PK": ["India", "China", "Afghanistan", "Iran"],
        "PA": ["Costa Rica", "Colombia"],
        "PG": ["Indonesia"],
        "PY": ["Argentina", "Bolivia", "Brazil"],
        "PE": ["Ecuador", "Colombia", "Brazil", "Bolivia", "Chile"],
        "PH": [],
        "PL": ["Germany", "Czech Republic", "Slovakia", "Ukraine", "Belarus", "Lithuania", "Russia"],
        "PT": ["Spain"],
        "QA": ["Saudi Arabia"],
        "RO": ["Ukraine", "Moldova", "Hungary", "Serbia", "Bulgaria"],
        "RU": [
            "Norway", "Finland", "Estonia", "Latvia", "Lithuania",
            "Poland", "Belarus", "Ukraine", "Georgia", "Azerbaijan",
            "Kazakhstan", "China", "Mongolia", "North Korea",
        ],
        "RW": ["Uganda", "Tanzania", "Burundi", "Democratic Republic of the Congo"],
        "SA": ["Jordan", "Iraq", "Kuwait", "Qatar", "United Arab Emirates", "Oman", "Yemen"],
        "SN": ["Mauritania", "Mali", "Guinea", "Guinea-Bissau", "Gambia"],
        "RS": [
            "Hungary", "Romania", "Bulgaria", "North Macedonia",
            "Kosovo", "Montenegro", "Bosnia and Herzegovina", "Croatia",
        ],
        "SL": ["Guinea", "Liberia"],
        "SG": [],
        "SK": ["Czech Republic", "Poland", "Ukraine", "Hungary", "Austria"],
        "SI": ["Italy", "Austria", "Hungary", "Croatia"],
        "SO": ["Ethiopia", "Djibouti", "Kenya"],
        "ZA": ["Namibia", "Botswana", "Zimbabwe", "Mozambique", "Eswatini", "Lesotho"],
        "SS": ["Sudan", "Ethiopia", "Kenya", "Uganda", "Democratic Republic of the Congo", "Central African Republic"],
        "ES": ["France", "Portugal", "Andorra", "Morocco"],
        "LK": [],
        "SD": ["Egypt", "Libya", "Chad", "Central African Republic", "South Sudan", "Ethiopia", "Eritrea"],
        "SR": ["Guyana", "Brazil"],
        "SE": ["Norway", "Finland"],
        "CH": ["Germany", "France", "Italy", "Austria", "Liechtenstein"],
        "SY": ["Turkey", "Iraq", "Jordan", "Israel", "Lebanon"],
        "TJ": ["China", "Kyrgyzstan", "Uzbekistan", "Afghanistan"],
        "TZ": [
            "Kenya", "Uganda", "Rwanda", "Burundi",
            "Democratic Republic of the Congo", "Zambia",
            "Malawi", "Mozambique",
        ],
        "TH": ["Myanmar", "Laos", "Cambodia", "Malaysia"],
        "TL": ["Indonesia"],
        "TG": ["Ghana", "Burkina Faso", "Benin"],
        "TN": ["Algeria", "Libya"],
        "TR": ["Bulgaria", "Greece", "Georgia", "Armenia", "Iran", "Iraq", "Syria"],
        "TM": ["Kazakhstan", "Uzbekistan", "Afghanistan", "Iran"],
        "UG": ["South Sudan", "Kenya", "Tanzania", "Rwanda", "Democratic Republic of the Congo"],
        "UA": ["Russia", "Belarus", "Poland", "Slovakia", "Hungary", "Romania", "Moldova"],
        "AE": ["Oman", "Saudi Arabia"],
        "GB": ["Ireland"],
        "US": ["Canada", "Mexico"],
        "UY": ["Argentina", "Brazil"],
        "UZ": ["Kazakhstan", "Kyrgyzstan", "Tajikistan", "Afghanistan", "Turkmenistan"],
        "VE": ["Colombia", "Brazil", "Guyana"],
        "VN": ["China", "Laos", "Cambodia"],
        "YE": ["Saudi Arabia", "Oman"],
        "ZM": [
            "Democratic Republic of the Congo", "Tanzania",
            "Malawi", "Mozambique", "Zimbabwe", "Botswana",
            "Namibia", "Angola",
        ],
        "ZW": ["Zambia", "Mozambique", "South Africa", "Botswana"],
        // Island nations
        "AG": [], "BB": [], "BS": [], "GD": [], "IS": [], "KI": [],
        "KM": [], "KN": [], "LC": [], "MH": [], "MU": [], "NR": [],
        "PW": [], "SB": [], "SC": [], "ST": [], "TO": [], "TT": [],
        "TV": [], "VC": [], "VU": [], "WS": [], "FJ": [], "FM": [],
        "TW": [], "BH": [],
    ]
}
