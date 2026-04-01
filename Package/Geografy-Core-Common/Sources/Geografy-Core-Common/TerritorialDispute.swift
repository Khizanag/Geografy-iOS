import Foundation

public struct TerritorialDispute: Identifiable, Sendable {
    public let id: String
    public let flag: String
    public let name: String
    public let geoJSONName: String?
    public let description: String
    public let region: Region
    public let options: [Option]
    public let defaultOptionKey: String

    public var userDefaultsKey: String { "territory_\(id)" }

    public init(
        id: String,
        flag: String,
        name: String,
        geoJSONName: String?,
        description: String,
        region: Region,
        options: [Option],
        defaultOptionKey: String
    ) {
        self.id = id
        self.flag = flag
        self.name = name
        self.geoJSONName = geoJSONName
        self.description = description
        self.region = region
        self.options = options
        self.defaultOptionKey = defaultOptionKey
    }

    public struct Option: Sendable {
        public let key: String
        public let label: String
        public let mergesInto: String?

        public init(key: String, label: String, mergesInto: String?) {
            self.key = key
            self.label = label
            self.mergesInto = mergesInto
        }
    }

    public enum Region: String, CaseIterable, Sendable {
        case europe = "Europe"
        case middleEastAsia = "Middle East & Asia"
        case africa = "Africa"
        case americas = "Americas"
    }
}

// MARK: - All Disputes
public extension TerritorialDispute {
    static let all: [TerritorialDispute] = [
        // Europe
        .init(
            id: "kosovo",
            flag: "🇽🇰",
            name: "Kosovo",
            geoJSONName: "Kosovo",
            description: "Declared independence from Serbia in 2008. Recognized by ~100 UN member states.",
            region: .europe,
            options: [
                .init(key: "separate", label: "Republic of Kosovo", mergesInto: nil),
                .init(key: "serbia", label: "Part of Serbia", mergesInto: "RS"),
            ],
            defaultOptionKey: "separate"
        ),
        .init(
            id: "northern_cyprus",
            flag: "🇨🇾",
            name: "Northern Cyprus",
            geoJSONName: "N. Cyprus",
            description: "Declared in 1983. Recognized only by Turkey; internationally considered part of Cyprus.",
            region: .europe,
            options: [
                .init(key: "cyprus", label: "Part of Cyprus", mergesInto: "CY"),
                .init(key: "separate", label: "Separate (TRNC)", mergesInto: nil),
            ],
            defaultOptionKey: "cyprus"
        ),
        .init(
            id: "crimea",
            flag: "🇺🇦",
            name: "Crimea",
            geoJSONName: "Crimea",
            description: "Annexed by Russia in 2014. 100 UN members affirmed Ukraine's territorial integrity.",
            region: .europe,
            options: [
                .init(key: "ukraine", label: "Part of Ukraine", mergesInto: "UA"),
                .init(key: "russia", label: "Part of Russia", mergesInto: "RU"),
            ],
            defaultOptionKey: "ukraine"
        ),
        .init(
            id: "transnistria",
            flag: "🇲🇩",
            name: "Transnistria",
            geoJSONName: "Transnistria",
            description: "Russian-backed breakaway region of Moldova since 1992. Unrecognized by any UN member state.",
            region: .europe,
            options: [
                .init(key: "moldova", label: "Part of Moldova", mergesInto: "MD"),
                .init(key: "separate", label: "Separate (unrecognized)", mergesInto: nil),
            ],
            defaultOptionKey: "moldova"
        ),
        // Middle East & Asia
        .init(
            id: "palestine",
            flag: "🇵🇸",
            name: "Palestine",
            geoJSONName: "Palestine",
            description: "UN observer state recognized by 146 member states. Includes the West Bank and Gaza Strip.",
            region: .middleEastAsia,
            options: [
                .init(key: "separate", label: "State of Palestine", mergesInto: nil),
                .init(key: "israel", label: "Israeli-administered", mergesInto: "IL"),
            ],
            defaultOptionKey: "separate"
        ),
        .init(
            id: "taiwan",
            flag: "🇹🇼",
            name: "Taiwan",
            geoJSONName: "Taiwan",
            description: "Self-governing island since 1949. Recognized by ~12 states; China claims full sovereignty.",
            region: .middleEastAsia,
            options: [
                .init(key: "separate", label: "Republic of China (Taiwan)", mergesInto: nil),
                .init(key: "china", label: "Part of China", mergesInto: "CN"),
            ],
            defaultOptionKey: "separate"
        ),
        .init(
            id: "golan_heights",
            flag: "🇸🇾",
            name: "Golan Heights",
            geoJSONName: "Golan",
            description: "Captured by Israel in 1967. Most see it as Syrian; US recognized Israeli sovereignty 2019.",
            region: .middleEastAsia,
            options: [
                .init(key: "syria", label: "Part of Syria", mergesInto: "SY"),
                .init(key: "israel", label: "Part of Israel", mergesInto: "IL"),
            ],
            defaultOptionKey: "syria"
        ),
        .init(
            id: "kashmir",
            flag: "🏔️",
            name: "Kashmir",
            geoJSONName: nil,
            description: "Disputed since the 1947 partition. Divided between India, Pakistan, and China.",
            region: .middleEastAsia,
            options: [
                .init(key: "disputed", label: "Disputed (as shown)", mergesInto: nil),
                .init(key: "india", label: "Part of India", mergesInto: nil),
                .init(key: "pakistan", label: "Part of Pakistan", mergesInto: nil),
            ],
            defaultOptionKey: "disputed"
        ),
        // Africa
        .init(
            id: "western_sahara",
            flag: "🇪🇭",
            name: "Western Sahara",
            geoJSONName: "W. Sahara",
            description: "Claimed by Morocco and the Sahrawi Arab Democratic Republic. African Union recognizes SADR.",
            region: .africa,
            options: [
                .init(key: "morocco", label: "Part of Morocco", mergesInto: "MA"),
                .init(key: "separate", label: "Sahrawi Republic (SADR)", mergesInto: nil),
            ],
            defaultOptionKey: "morocco"
        ),
        .init(
            id: "somaliland",
            flag: "🇸🇴",
            name: "Somaliland",
            geoJSONName: "Somaliland",
            description: "Self-declared republic since 1991. Stable and self-governing; internationally unrecognized.",
            region: .africa,
            options: [
                .init(key: "somalia", label: "Part of Somalia", mergesInto: "SO"),
                .init(key: "separate", label: "Separate (Somaliland)", mergesInto: nil),
            ],
            defaultOptionKey: "somalia"
        ),
        // Americas
        .init(
            id: "falkland_islands",
            flag: "🇫🇰",
            name: "Falkland Islands",
            geoJSONName: "Falkland Is.",
            description: "British Overseas Territory since 1833. Claimed by Argentina as 'Islas Malvinas'.",
            region: .americas,
            options: [
                .init(key: "uk", label: "British Territory", mergesInto: nil),
                .init(key: "argentina", label: "Argentine Territory (Malvinas)", mergesInto: "AR"),
            ],
            defaultOptionKey: "uk"
        ),
    ]

    static func grouped() -> [(region: Region, disputes: [TerritorialDispute])] {
        Region.allCases.compactMap { region in
            let disputes = all.filter { $0.region == region }
            guard !disputes.isEmpty else { return nil }
            return (region: region, disputes: disputes)
        }
    }
}
