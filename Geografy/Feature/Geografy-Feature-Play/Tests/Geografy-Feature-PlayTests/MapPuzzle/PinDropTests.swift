import CoreGraphics
import Foundation
import Geografy_Core_Common
@testable import Geografy_Feature_Play
import SwiftUI
import Testing

// MARK: - Geometry
@Suite("PinDrop geometry")
struct PinDropGeometryTests {
    @Test("Madrid to Paris is about 1,050 km")
    func madridToParis() {
        let madrid = GeoCoordinate(latitude: 40.4168, longitude: -3.7038)
        let paris = GeoCoordinate(latitude: 48.8566, longitude: 2.3522)

        let distance = PinDropGeometry.distanceKilometers(from: madrid, to: paris)

        #expect(abs(distance - 1_053) < 10)
    }

    @Test("A place is no distance from itself")
    func zeroDistance() {
        let tbilisi = GeoCoordinate(latitude: 41.7151, longitude: 44.8271)
        #expect(PinDropGeometry.distanceKilometers(from: tbilisi, to: tbilisi) < 0.001)
    }

    @Test("The nearest point of a square lies on its closest edge")
    func nearestPointOnEdge() throws {
        let square = CGPath(rect: CGRect(x: 0, y: 0, width: 10, height: 10), transform: nil)

        let nearest = try #require(PinDropGeometry.nearestPoint(to: CGPoint(x: 15, y: 5), on: [square]))

        #expect(nearest == CGPoint(x: 10, y: 5))
    }

    @Test("The nearest point to a far corner is the corner")
    func nearestPointAtCorner() throws {
        let square = CGPath(rect: CGRect(x: 0, y: 0, width: 10, height: 10), transform: nil)

        let nearest = try #require(PinDropGeometry.nearestPoint(to: CGPoint(x: -4, y: -4), on: [square]))

        #expect(nearest == .zero)
    }

    @Test("A map point and its place agree")
    func projectionRoundTrip() {
        let point = MapProjection.project(longitude: 44.8, latitude: 41.7)
        let coordinate = GeoCoordinate(mapPoint: point)

        #expect(abs(coordinate.latitude - 41.7) < 0.0001)
        #expect(abs(coordinate.longitude - 44.8) < 0.0001)
    }
}

// MARK: - Scoring
@Suite("PinDrop scoring")
struct PinDropScoringTests {
    private let europeSpan = PinDropRegion.europe.spanKilometers
    private let spainArea = 505_990.0

    @Test("A pin inside the country earns full accuracy and a bullseye")
    func insideIsPerfect() {
        let score = PinDropScoring.score(
            distanceKilometers: 0, isInside: true, regionSpanKilometers: europeSpan,
            countryArea: spainArea, seconds: 30, streak: 0
        )

        #expect(score.accuracyPoints == PinDropScoring.maxAccuracyPoints)
        #expect(score.rating == .bullseye)
        #expect(score.speedBonus == 0)
    }

    @Test("Accuracy falls as the pin lands farther away")
    func accuracyFalls() {
        let distances = [0.0, 100, 300, 800, 2_000]
        let points = distances.map { distance in
            PinDropScoring.accuracyPoints(
                distanceKilometers: distance, regionSpanKilometers: europeSpan, countryArea: spainArea
            )
        }

        #expect(points == points.sorted(by: >))
        #expect(points.last ?? 0 < 100)
    }

    @Test("A small miss of a big country is forgiven")
    func pinWidthForgiven() {
        let points = PinDropScoring.accuracyPoints(
            distanceKilometers: 30, regionSpanKilometers: europeSpan, countryArea: spainArea
        )
        #expect(points == PinDropScoring.maxAccuracyPoints)
    }

    @Test("The same miss costs less on the world map than in Europe")
    func regionScales() {
        let inEurope = PinDropScoring.accuracyPoints(
            distanceKilometers: 500, regionSpanKilometers: europeSpan, countryArea: spainArea
        )
        let onWorld = PinDropScoring.accuracyPoints(
            distanceKilometers: 500, regionSpanKilometers: PinDropRegion.world.spanKilometers, countryArea: spainArea
        )
        #expect(onWorld > inEurope)
    }

    @Test("Speed pays only with accuracy")
    func speedNeedsAccuracy() {
        #expect(PinDropScoring.speedBonus(accuracyPoints: 1_000, seconds: 2) == PinDropScoring.maxSpeedBonus)
        #expect(PinDropScoring.speedBonus(accuracyPoints: 0, seconds: 2) == 0)
        #expect(PinDropScoring.speedBonus(accuracyPoints: 1_000, seconds: 25) == 0)
    }

    @Test("Excellent rounds in a row grow a multiplier, capped at 50%")
    func streakMultiplier() {
        let first = PinDropScoring.score(
            distanceKilometers: 0, isInside: true, regionSpanKilometers: europeSpan,
            countryArea: spainArea, seconds: 30, streak: 0
        )
        let third = PinDropScoring.score(
            distanceKilometers: 0, isInside: true, regionSpanKilometers: europeSpan,
            countryArea: spainArea, seconds: 30, streak: 2
        )
        let long = PinDropScoring.score(
            distanceKilometers: 0, isInside: true, regionSpanKilometers: europeSpan,
            countryArea: spainArea, seconds: 30, streak: 20
        )

        #expect(first.streakMultiplier == 1)
        #expect(abs(third.streakMultiplier - 1.2) < 0.0001)
        #expect(abs(long.streakMultiplier - 1.5) < 0.0001)
        #expect(third.total == 1_200)
    }

    @Test("A far miss breaks the streak")
    func streakBreaks() {
        let score = PinDropScoring.score(
            distanceKilometers: 3_000, isInside: false, regionSpanKilometers: europeSpan,
            countryArea: spainArea, seconds: 5, streak: 4
        )
        #expect(score.streak == 0)
        #expect(score.streakMultiplier == 1)
        #expect(score.rating == .far)
    }

    @Test("Grades follow the share of a perfect game")
    func grades() {
        #expect(PinDropScoring.grade(totalPoints: 9_600, roundCount: 10) == .s)
        #expect(PinDropScoring.grade(totalPoints: 8_000, roundCount: 10) == .a)
        #expect(PinDropScoring.grade(totalPoints: 6_500, roundCount: 10) == .b)
        #expect(PinDropScoring.grade(totalPoints: 4_000, roundCount: 10) == .c)
        #expect(PinDropScoring.grade(totalPoints: 1_000, roundCount: 10) == .d)
        #expect(PinDropScoring.grade(totalPoints: 0, roundCount: 0) == .d)
    }
}

// MARK: - Game
@Suite("PinDrop game")
@MainActor
struct PinDropGameTests {
    private let square = CGPath(rect: CGRect(x: 1_000, y: 700, width: 20, height: 20), transform: nil)

    private func round(code: String, area: Double = 300_000) -> PinDropGame.Round {
        let country = Country.sample(code: code, area: area)
        let shape = CountryShape(
            id: code, name: code, continent: "Europe", polygons: [square],
            centroid: CGPoint(x: 1_010, y: 710), boundingBox: CGRect(x: 1_000, y: 700, width: 20, height: 20),
            color: .blue
        )
        return PinDropGame.Round(country: country, shape: shape)
    }

    @Test("A pin inside scores a bullseye; the next round starts clean")
    func playThrough() throws {
        let start = Date(timeIntervalSince1970: 0)
        let game = PinDropGame(
            configuration: PinDropConfiguration(roundCount: 2),
            rounds: [round(code: "AA"), round(code: "BB")],
            now: start
        )

        game.dropPin(at: CGPoint(x: 1_010, y: 710))
        let result = try #require(game.lockIn(now: start.addingTimeInterval(3)))

        #expect(result.isInside)
        #expect(result.score.rating == .bullseye)
        #expect(game.phase == .revealed)

        game.advance()
        #expect(game.phase == .aiming)
        #expect(game.pin == nil)
        #expect(game.currentRound?.id == "BB")
    }

    @Test("A pin outside measures to the border, and the last round ends the game")
    func missAndFinish() throws {
        let game = PinDropGame(configuration: PinDropConfiguration(roundCount: 1), rounds: [round(code: "AA")])

        game.dropPin(at: CGPoint(x: 1_050, y: 710))
        let result = try #require(game.lockIn())

        #expect(!result.isInside)
        #expect(result.nearestPoint == CGPoint(x: 1_020, y: 710))
        #expect(result.distanceKilometers > 0)

        game.advance()
        #expect(game.phase == .finished)
    }

    @Test("Picking the right country is a bullseye, wherever its middle is")
    func pickRightCountry() throws {
        let target = round(code: "AA")
        let game = PinDropGame(configuration: PinDropConfiguration(roundCount: 1), rounds: [target])

        game.selectCountry(target.shape)
        let result = try #require(game.lockIn())

        #expect(result.isInside)
        #expect(result.guessedCountryCode == "AA")
        #expect(result.score.rating == .bullseye)
    }

    @Test("Picking another country measures from its middle to the answer's border")
    func pickWrongCountry() throws {
        let game = PinDropGame(configuration: PinDropConfiguration(roundCount: 1), rounds: [round(code: "AA")])
        let neighbor = CountryShape(
            id: "BB", name: "BB", continent: "Europe",
            polygons: [CGPath(rect: CGRect(x: 1_020, y: 700, width: 20, height: 20), transform: nil)],
            centroid: CGPoint(x: 1_030, y: 710), boundingBox: CGRect(x: 1_020, y: 700, width: 20, height: 20),
            color: .blue
        )

        game.selectCountry(neighbor)
        let result = try #require(game.lockIn())

        #expect(!result.isInside)
        #expect(result.guessedCountryCode == "BB")
        #expect(result.pin == CGPoint(x: 1_030, y: 710))
        #expect(result.nearestPoint == CGPoint(x: 1_020, y: 710))
        #expect(result.distanceKilometers > 0)
    }

    @Test("Locking in needs a pin")
    func lockInNeedsPin() {
        let game = PinDropGame(configuration: PinDropConfiguration(roundCount: 1), rounds: [round(code: "AA")])
        #expect(game.lockIn() == nil)
        #expect(game.phase == .aiming)
    }

    @Test("Rounds keep to the region and the difficulty's size")
    func roundSelection() {
        let spain = Country.sample(code: "ES", area: 505_990, continent: .europe)
        let monaco = Country.sample(code: "MC", area: 2, continent: .europe)
        let japan = Country.sample(code: "JP", area: 377_975, continent: .asia)
        let madrid = MapProjection.project(longitude: -3.7, latitude: 40.4)
        let monacoPoint = MapProjection.project(longitude: 7.4, latitude: 43.7)
        let tokyo = MapProjection.project(longitude: 139.7, latitude: 35.7)
        let shapes = [("ES", madrid), ("MC", monacoPoint), ("JP", tokyo)].map { code, point in
            CountryShape(
                id: code, name: code, continent: "", polygons: [],
                centroid: point, boundingBox: CGRect(origin: point, size: .zero), color: .blue
            )
        }
        var generator = SystemRandomNumberGenerator()

        let standard = PinDropGame.makeRounds(
            for: PinDropConfiguration(region: .europe, difficulty: .standard, roundCount: 10),
            countries: [spain, monaco, japan], shapes: shapes, using: &generator
        )
        let expert = PinDropGame.makeRounds(
            for: PinDropConfiguration(region: .europe, difficulty: .expert, roundCount: 10),
            countries: [spain, monaco, japan], shapes: shapes, using: &generator
        )

        #expect(standard.map(\.id) == ["ES"])
        #expect(Set(expert.map(\.id)) == ["ES", "MC"])
    }
}

// MARK: - Records
@Suite("PinDrop records")
struct PinDropRecordsTests {
    @Test("Only a higher score becomes the record")
    func keepsBest() throws {
        let suite = "PinDropRecordsTests.keepsBest"
        let defaults = try #require(UserDefaults(suiteName: suite))
        // Cleared first too, so a run that crashed before its cleanup can't leave a record behind.
        defaults.removePersistentDomain(forName: suite)
        defer { defaults.removePersistentDomain(forName: suite) }
        let records = PinDropRecords(defaults: defaults)
        let configuration = PinDropConfiguration()

        #expect(records.record(500, for: configuration))
        #expect(!records.record(400, for: configuration))
        #expect(records.best(for: configuration) == 500)
        #expect(records.best(for: PinDropConfiguration(region: .asia)) == 0)
        #expect(records.best(for: PinDropConfiguration(showsBorders: false)) == 0)
    }
}

// MARK: - Fixtures
private extension Country {
    static func sample(code: String, area: Double, continent: Continent = .europe) -> Country {
        Country(
            code: code, name: code, capital: "", flagEmoji: "", continent: continent,
            area: area, population: 0, populationDensity: 0, currency: Currency(name: "", code: ""),
            languages: [], formOfGovernment: "", gdp: nil, gdpPerCapita: nil, gdpPPP: nil, organizations: []
        )
    }
}
