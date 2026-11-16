import Foundation
import Geografy_Core_Common
@testable import Geografy_Feature_Discover
import Testing

@MainActor
@Suite("Time zone grouping and labels")
struct TimeZoneGroupTests {
    @Test("Groups countries by offset, west to east, each group by name")
    func groupsByOffset() throws {
        let countries = try [
            Self.item(code: "GE", name: "Georgia", zone: "Asia/Tbilisi"),
            Self.item(code: "AE", name: "United Arab Emirates", zone: "Asia/Dubai"),
            Self.item(code: "AM", name: "Armenia", zone: "Asia/Yerevan"),
            Self.item(code: "IN", name: "India", zone: "Asia/Kolkata"),
        ]

        let groups = TimeZoneGroup.groups(from: countries)

        #expect(groups.map(\.offset) == [4, 5.5])
        #expect(groups.first?.countries.map(\.country.name) == ["Armenia", "Georgia", "United Arab Emirates"])
    }

    @Test(
        "Labels whole and fractional offsets",
        arguments: [
            (4.0, "UTC+4"),
            (0.0, "UTC+0"),
            (-5.0, "UTC-5"),
            (5.5, "UTC+5:30"),
            (5.75, "UTC+5:45"),
        ]
    )
    func offsetLabels(hours: Double, label: String) {
        #expect(CountryWithZone.utcOffsetLabel(forHours: hours) == label)
    }

    @Test("Formats the clock in the zone it's asked for")
    func formatsInZone() throws {
        let tbilisi = try #require(TimeZone(identifier: "Asia/Tbilisi"))
        let utc = try #require(TimeZone(identifier: "UTC"))
        let date = Date(timeIntervalSince1970: 0)

        let utcTime = ZoneClockFormatter.time(date, in: utc)
        let cachedUTCTime = ZoneClockFormatter.time(date, in: utc)

        #expect(ZoneClockFormatter.time(date, in: tbilisi) != utcTime)
        #expect(cachedUTCTime == utcTime)
    }
}

// MARK: - Fixtures
private extension TimeZoneGroupTests {
    static func item(code: String, name: String, zone: String) throws -> CountryWithZone {
        let country = Country(
            code: code,
            name: name,
            capital: "",
            flagEmoji: "",
            continent: .asia,
            area: 1,
            population: 1,
            populationDensity: 1,
            currency: Country.Currency(name: "", code: ""),
            languages: [],
            formOfGovernment: "",
            gdp: nil,
            gdpPerCapita: nil,
            gdpPPP: nil,
            organizations: []
        )
        return CountryWithZone(country: country, timeZone: try #require(TimeZone(identifier: zone)))
    }
}
