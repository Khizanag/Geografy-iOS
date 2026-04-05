import Foundation
import Geografy_Core_Common

public struct BorderChallengeService {
    public enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"

        var neighborRange: ClosedRange<Int> {
            switch self {
            case .easy: 1...3
            case .medium: 4...6
            case .hard: 7...30
            }
        }

        var xpMultiplier: Int {
            switch self {
            case .easy: 1
            case .medium: 2
            case .hard: 3
            }
        }

        var timeLimit: Int {
            switch self {
            case .easy: 60
            case .medium: 90
            case .hard: 120
            }
        }

        public var icon: String {
            switch self {
            case .easy: "leaf.fill"
            case .medium: "flame.fill"
            case .hard: "bolt.fill"
            }
        }

        public var subtitle: String {
            switch self {
            case .easy: "1–3 neighbors"
            case .medium: "4–6 neighbors"
            case .hard: "7+ neighbors"
            }
        }
    }

    public func selectCountry(from countries: [Country], difficulty: Difficulty) -> Country? {
        let eligible = countries.filter { country in
            let count = CountryNeighbors.neighbors(for: country.code).count
            return difficulty.neighborRange.contains(count)
        }
        return eligible.randomElement()
    }

    public func neighbors(for country: Country, in countries: [Country]) -> [Country] {
        let codes = CountryNeighbors.neighbors(for: country.code)
        return codes.compactMap { code in countries.first { $0.code == code } }
    }

    public func isCorrectGuess(_ input: String, for neighbors: [Country]) -> Country? {
        let normalized = input.trimmingCharacters(in: .whitespaces).lowercased()
        guard !normalized.isEmpty else { return nil }
        return neighbors.first { country in
            country.name.lowercased() == normalized
                || alternateNames(for: country.code).contains { $0.lowercased() == normalized }
        }
    }

    public func xpEarned(found: Int, total: Int, difficulty: Difficulty) -> Int {
        found * 10 * difficulty.xpMultiplier
    }
}

// MARK: - Alternate Names
private extension BorderChallengeService {
    static let alternateNameMap: [String: [String]] = [
        "US": ["united states", "usa", "america", "united states of america"],
        "GB": ["united kingdom", "uk", "england", "britain", "great britain"],
        "RU": ["russia", "russian federation"],
        "KR": ["south korea", "korea south"],
        "KP": ["north korea", "korea north"],
        "CD": ["congo", "drc", "dr congo", "democratic republic of the congo"],
        "CG": ["republic of congo", "congo republic"],
        "IR": ["iran"],
        "VN": ["vietnam"],
        "LA": ["laos"],
        "MM": ["myanmar", "burma"],
        "CI": ["ivory coast", "cote d'ivoire"],
        "MK": ["north macedonia", "macedonia"],
        "MD": ["moldova"],
        "TZ": ["tanzania"],
        "CZ": ["czech republic", "czechia"],
    ]

    func alternateNames(for code: String) -> [String] {
        Self.alternateNameMap[code] ?? []
    }
}
