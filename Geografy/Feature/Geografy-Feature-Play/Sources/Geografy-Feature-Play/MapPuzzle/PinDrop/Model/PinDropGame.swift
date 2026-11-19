import CoreGraphics
import Foundation
import Geografy_Core_Common
import Observation

/// How a Pin Drop game is set up.
public struct PinDropConfiguration: Hashable, Codable, Sendable {
    public var region: PinDropRegion
    public var difficulty: PinDropDifficulty
    public var roundCount: Int
    /// Whether countries are outlined and tinted apart; without, only coastlines show.
    /// With borders the player picks a whole country; without, they drop a pin.
    public var showsBorders: Bool

    public static let roundCounts = [5, 10, 15]

    public init(
        region: PinDropRegion = .europe,
        difficulty: PinDropDifficulty = .standard,
        roundCount: Int = 10,
        showsBorders: Bool = true
    ) {
        self.region = region
        self.difficulty = difficulty
        self.roundCount = roundCount
        self.showsBorders = showsBorders
    }
}

/// Which countries can be asked.
public enum PinDropDifficulty: String, CaseIterable, Codable, Identifiable, Sendable {
    /// Countries big enough to see without zooming.
    case standard
    /// Every country, microstates and islands included.
    case expert

    public var id: String { rawValue }

    /// Smallest area asked, in km².
    var minimumArea: Double {
        switch self {
        case .standard: 20_000
        case .expert: 0
        }
    }
}

/// One Pin Drop game: the countries to find, where each pin landed, and how it scored.
@MainActor
@Observable
final class PinDropGame {
    // MARK: - Types
    enum Phase: Equatable {
        case aiming
        case revealed
        case finished
    }

    struct Round: Identifiable {
        let country: Country
        let shape: CountryShape

        var id: String { country.code }
    }

    struct Result: Identifiable {
        let round: Round
        /// Where the pin landed, in map coordinates.
        let pin: CGPoint
        /// The country's border point nearest the pin; the pin itself when it landed inside.
        let nearestPoint: CGPoint
        /// The country picked, when the player picks countries instead of dropping a pin.
        let guessedCountryCode: String?
        let distanceKilometers: Double
        let isInside: Bool
        let score: PinDropScore

        var id: String { round.id }
    }

    // MARK: - Properties
    let configuration: PinDropConfiguration
    let rounds: [Round]

    private(set) var currentIndex = 0
    private(set) var phase: Phase = .aiming
    private(set) var pin: CGPoint?
    /// The country picked so far, when picking countries; `pin` is then its middle.
    private(set) var selectedCountryCode: String?
    private(set) var results: [Result] = []
    private var roundStartedAt: Date

    // MARK: - Init
    init(configuration: PinDropConfiguration, rounds: [Round], now: Date = .now) {
        self.configuration = configuration
        self.rounds = rounds
        roundStartedAt = now
        if rounds.isEmpty { phase = .finished }
    }

    // MARK: - State
    var currentRound: Round? {
        rounds.indices.contains(currentIndex) ? rounds[currentIndex] : nil
    }

    var lastResult: Result? { results.last }

    var totalScore: Int { results.reduce(0) { $0 + $1.score.total } }

    var streak: Int { results.last?.score.streak ?? 0 }

    var isLastRound: Bool { currentIndex >= rounds.count - 1 }
}

// MARK: - Actions
extension PinDropGame {
    /// Places the pin, or moves it, until the guess is locked in.
    func dropPin(at mapPoint: CGPoint) {
        guard phase == .aiming else { return }
        pin = mapPoint
        selectedCountryCode = nil
    }

    /// Picks a whole country as the guess, or another one, until the guess is locked in.
    /// A wrong pick is measured from its middle, so picking a neighbor still scores well.
    func selectCountry(_ shape: CountryShape) {
        guard phase == .aiming else { return }
        selectedCountryCode = shape.id
        pin = shape.centroid
    }

    /// Scores the pin against the current country.
    @discardableResult
    func lockIn(now: Date = .now) -> Result? {
        guard phase == .aiming, let pin, let round = currentRound else { return nil }

        let isInside = selectedCountryCode.map { $0 == round.id } ?? round.shape.contains(pin)
        let nearest = isInside ? pin : PinDropGeometry.nearestPoint(to: pin, on: round.shape.polygons) ?? pin
        let distance = isInside ? 0 : PinDropGeometry.distanceKilometers(
            from: GeoCoordinate(mapPoint: pin),
            to: GeoCoordinate(mapPoint: nearest)
        )
        let score = PinDropScoring.score(
            distanceKilometers: distance,
            isInside: isInside,
            regionSpanKilometers: configuration.region.spanKilometers,
            countryArea: round.country.area,
            seconds: now.timeIntervalSince(roundStartedAt),
            streak: streak
        )
        let result = Result(
            round: round,
            pin: pin,
            nearestPoint: nearest,
            guessedCountryCode: selectedCountryCode,
            distanceKilometers: distance,
            isInside: isInside,
            score: score
        )
        results.append(result)
        phase = .revealed
        return result
    }

    /// Moves on to the next country, or ends the game after the last.
    func advance(now: Date = .now) {
        guard phase == .revealed else { return }
        pin = nil
        selectedCountryCode = nil
        if isLastRound {
            phase = .finished
        } else {
            currentIndex += 1
            roundStartedAt = now
            phase = .aiming
        }
    }
}

// MARK: - Building Rounds
extension PinDropGame {
    /// The countries of the region with an outline on the map, as large as the difficulty asks, shuffled.
    static func makeRounds(
        for configuration: PinDropConfiguration,
        countries: [Country],
        shapes: [CountryShape],
        using generator: inout some RandomNumberGenerator
    ) -> [Round] {
        let shapesByCode = Dictionary(shapes.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let regionRect = configuration.region.mapRect
        let candidates = countries.compactMap { country -> Round? in
            guard configuration.region.continent.map({ country.continent == $0 }) ?? true,
                  country.area >= configuration.difficulty.minimumArea,
                  let shape = shapesByCode[country.code],
                  regionRect.contains(CGPoint(x: shape.centroid.x, y: shape.centroid.y))
            else { return nil }
            return Round(country: country, shape: shape)
        }
        return Array(candidates.shuffled(using: &generator).prefix(configuration.roundCount))
    }
}
