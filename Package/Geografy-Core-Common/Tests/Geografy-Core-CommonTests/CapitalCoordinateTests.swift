import Foundation
@testable import Geografy_Core_Common
import Testing

@Suite("Capital coordinates")
struct CapitalCoordinateTests {
    @Test("A country decodes its capital's coordinate")
    func decodesCoordinate() throws {
        let country = try decode(extra: #""capitalLatitude": 48.857, "capitalLongitude": 2.352,"#)

        #expect(country.capitalCoordinate == GeoCoordinate(latitude: 48.857, longitude: 2.352))
    }

    @Test("A country without coordinates has no capital coordinate")
    func missingCoordinateIsNil() throws {
        let country = try decode(extra: "")

        #expect(country.capitalCoordinate == nil)
    }

    @Test("Places on the map that aren't countries still have a capital")
    func territoriesHaveCapitals() {
        #expect(MapTerritory.info(for: "GL")?.capital == "Nuuk")
        #expect(MapTerritory.info(for: "EH") != nil)
        #expect(MapTerritory.info(for: "FR") == nil)
    }
}

// MARK: - Helpers
private extension CapitalCoordinateTests {
    func decode(extra: String) throws -> Country {
        let json = """
        {
            "code": "FR", "name": "France", "capital": "Paris", \(extra)
            "flagEmoji": "🇫🇷", "continent": "europe", "area": 551695, "population": 68000000,
            "populationDensity": 123, "currency": { "name": "Euro", "code": "EUR" }, "languages": [],
            "formOfGovernment": "Republic", "organizations": []
        }
        """
        return try JSONDecoder().decode(Country.self, from: Data(json.utf8))
    }
}
