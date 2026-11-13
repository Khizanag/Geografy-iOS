import Foundation

public struct CountryProfileService {
    // Decoded once per launch; every country screen reads the same table.
    private static let sharedProfiles = loadProfiles()

    private let profiles: [String: CountryProfile]

    public init() {
        profiles = Self.sharedProfiles
    }

    public func profile(for countryCode: String) -> CountryProfile? {
        profiles[countryCode.uppercased()]
    }

    public var availableCountryCodes: Set<String> {
        Set(profiles.keys)
    }
}

// MARK: - Loading
private extension CountryProfileService {
    static func loadProfiles() -> [String: CountryProfile] {
        guard let url = Bundle.main.url(
            forResource: "country_profiles",
            withExtension: "json"
        ) else {
            return [:]
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(
                [String: CountryProfile].self,
                from: data
            )
        } catch {
            return [:]
        }
    }
}
