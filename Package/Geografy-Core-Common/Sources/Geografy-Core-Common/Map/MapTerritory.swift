/// Places drawn on the map that aren't in the country list, with what the map shows when one is tapped.
public enum MapTerritory {
    public struct Info: Sendable {
        public let flag: String
        public let capital: String
        public let capitalCoordinate: GeoCoordinate
    }

    public static func info(for code: String) -> Info? {
        all[code]
    }

    private static let all: [String: Info] = [
        "EH": Info(
            flag: "🇪🇭",
            capital: "Laayoune",
            capitalCoordinate: GeoCoordinate(latitude: 27.163, longitude: -13.203)
        ),
        "GL": Info(
            flag: "🇬🇱",
            capital: "Nuuk",
            capitalCoordinate: GeoCoordinate(latitude: 64.175, longitude: -51.739)
        ),
    ]
}
