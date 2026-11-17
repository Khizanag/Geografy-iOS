import Foundation
import Geografy_Core_Common

/// How a Pin Drop guess turns into points.
///
/// - **Accuracy**, up to 1,000: full marks inside the country; outside, points fall off with the distance
///   to its border. The falloff widens with the region's size, so a miss counts for less on the whole world
///   than in Europe, and with the country's size, so tiny countries forgive more than vast ones.
///   A sliver of the distance is forgiven outright, since a pin is wider than a border line.
/// - **Speed**, up to 200: the quicker the pin, the more, but only in proportion to how accurate it was,
///   so a fast wild guess earns nothing.
/// - **Streak**: each excellent round in a row after the first adds 10% to the round, up to 50%.
enum PinDropScoring {
    static let maxAccuracyPoints = 1_000
    static let maxSpeedBonus = 200
    /// Accuracy that keeps a streak going.
    static let streakThreshold = 850
    static let maxStreakSteps = 5

    /// Seconds a guess can take and still earn the whole speed bonus, and when it earns none.
    static let fullSpeedSeconds: Double = 4
    static let noSpeedSeconds: Double = 20

    /// - Parameters:
    ///   - distanceKilometers: From the pin to the country's border; ignored when `isInside`.
    ///   - streak: Excellent rounds in a row before this one.
    static func score(
        distanceKilometers: Double,
        isInside: Bool,
        regionSpanKilometers: Double,
        countryArea: Double,
        seconds: Double,
        streak: Int
    ) -> PinDropScore {
        let accuracy = accuracyPoints(
            distanceKilometers: isInside ? 0 : distanceKilometers,
            regionSpanKilometers: regionSpanKilometers,
            countryArea: countryArea
        )
        let speed = speedBonus(accuracyPoints: accuracy, seconds: seconds)
        let keepsStreak = accuracy >= streakThreshold
        let newStreak = keepsStreak ? streak + 1 : 0
        let multiplier = 1 + 0.1 * Double(min(max(newStreak - 1, 0), maxStreakSteps))
        let total = Int((Double(accuracy + speed) * multiplier).rounded())

        return PinDropScore(
            accuracyPoints: accuracy,
            speedBonus: speed,
            streakMultiplier: multiplier,
            total: total,
            streak: newStreak,
            rating: isInside ? .bullseye : PinDropScore.Rating(accuracyPoints: accuracy)
        )
    }

    static func accuracyPoints(distanceKilometers: Double, regionSpanKilometers: Double, countryArea: Double) -> Int {
        let radius = PinDropGeometry.equivalentRadiusKilometers(forArea: countryArea)
        let forgiven = min(radius * 0.1, 50)
        let missed = max(distanceKilometers - forgiven, 0)
        guard missed > 0 else { return maxAccuracyPoints }

        let falloff = regionSpanKilometers * 0.08 + radius * 0.4
        let fraction = exp(-missed / max(falloff, 1))
        return Int((Double(maxAccuracyPoints) * fraction).rounded())
    }

    static func speedBonus(accuracyPoints: Int, seconds: Double) -> Int {
        let pace = 1 - (seconds - fullSpeedSeconds) / (noSpeedSeconds - fullSpeedSeconds)
        let speed = min(max(pace, 0), 1)
        let accuracy = Double(accuracyPoints) / Double(maxAccuracyPoints)
        return Int((Double(maxSpeedBonus) * speed * accuracy * accuracy).rounded())
    }

    /// A letter for a whole game, from its points against a perfect-accuracy game without bonuses.
    static func grade(totalPoints: Int, roundCount: Int) -> PinDropGrade {
        guard roundCount > 0 else { return .d }
        let fraction = Double(totalPoints) / Double(roundCount * maxAccuracyPoints)
        return switch fraction {
        case 0.95...: .s
        case 0.8..<0.95: .a
        case 0.6..<0.8: .b
        case 0.4..<0.6: .c
        default: .d
        }
    }
}

// MARK: - Score
struct PinDropScore: Equatable, Sendable {
    let accuracyPoints: Int
    let speedBonus: Int
    let streakMultiplier: Double
    let total: Int
    /// Excellent rounds in a row, this one included.
    let streak: Int
    let rating: Rating

    enum Rating: Equatable, Sendable {
        case bullseye
        case excellent
        case good
        case fair
        case far

        init(accuracyPoints: Int) {
            self = switch accuracyPoints {
            case PinDropScoring.streakThreshold...: .excellent
            case 600..<PinDropScoring.streakThreshold: .good
            case 300..<600: .fair
            default: .far
            }
        }
    }
}

// MARK: - XP
extension PinDropScoring {
    /// What a finished game earns: by rounds played and how close the pins were on average.
    static func xp(for results: [PinDropGame.Result]) -> Int {
        guard !results.isEmpty else { return 0 }
        let total = results.reduce(0) { $0 + Double($1.score.accuracyPoints) }
        let averageAccuracy = total / Double(results.count * maxAccuracyPoints)
        return XPRules.pinDrop(rounds: results.count, averageAccuracy: averageAccuracy)
    }
}

// MARK: - Grade
enum PinDropGrade: String, Sendable {
    case s = "S"
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
}
