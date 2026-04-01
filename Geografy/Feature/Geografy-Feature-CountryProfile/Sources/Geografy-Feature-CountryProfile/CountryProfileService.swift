import Foundation

public struct CountryProfileService {
    private let profiles: [String: CountryProfile]

    public init() {
        profiles = Self.loadProfiles()
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
