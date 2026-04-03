import Foundation

public enum CountryBasicInfo {
    public struct Info: Sendable {
        public let flag: String
        public let capital: String
        public let capitalLatitude: Double
        public let capitalLongitude: Double

        public init(
            flag: String,
            capital: String,
            capitalLatitude: Double,
            capitalLongitude: Double
        ) {
            self.flag = flag
            self.capital = capital
            self.capitalLatitude = capitalLatitude
            self.capitalLongitude = capitalLongitude
        }
    }

    public static func info(for code: String) -> Info? {
        data[code]
    }
}

// MARK: - Data Loading
private extension CountryBasicInfo {
    struct JSONEntry: Decodable {
        let code: String
        let flag: String
        let capital: String
        let capitalLatitude: Double
        let capitalLongitude: Double
    }

    static let data: [String: Info] = {
        guard let url = Bundle.module.url(
            forResource: "country_basic_info",
            withExtension: "json"
        ),
              let jsonData = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([JSONEntry].self, from: jsonData)
        else { return [:] }

        return Dictionary(uniqueKeysWithValues: entries.map { entry in
            (
                entry.code,
                Info(
                    flag: entry.flag,
                    capital: entry.capital,
                    capitalLatitude: entry.capitalLatitude,
                    capitalLongitude: entry.capitalLongitude
                )
            )
        })
    }()
}
