import Foundation
import Geografy_Core_Common

public struct FlagColorEntry: Decodable, Sendable {
    public let name: String
    public let hex: String
    public let meaning: String

    public init(name: String, hex: String, meaning: String) {
        self.name = name
        self.hex = hex
        self.meaning = meaning
    }
}

public struct FlagEmblemEntry: Decodable, Sendable {
    public let name: String
    public let symbol: String
    public let meaning: String

    public init(name: String, symbol: String, meaning: String) {
        self.name = name
        self.symbol = symbol
        self.meaning = meaning
    }
}

public struct FlagSymbolism: Decodable, Sendable {
    public let adoptedYear: Int?
    public let colors: [FlagColorEntry]
    public let emblems: [FlagEmblemEntry]
    public let historicalNote: String?

    public init(adoptedYear: Int?, colors: [FlagColorEntry], emblems: [FlagEmblemEntry], historicalNote: String?) {
        self.adoptedYear = adoptedYear
        self.colors = colors
        self.emblems = emblems
        self.historicalNote = historicalNote
    }
}

// MARK: - Data
/// What each flag's colors and emblems stand for, keyed by country code, from `flag_symbolism.json`.
public enum FlagSymbolismData: Sendable {
    public static let data = BundledJSON.decode(
        [String: FlagSymbolism].self,
        named: "flag_symbolism",
        in: .module
    ) ?? [:]
}
