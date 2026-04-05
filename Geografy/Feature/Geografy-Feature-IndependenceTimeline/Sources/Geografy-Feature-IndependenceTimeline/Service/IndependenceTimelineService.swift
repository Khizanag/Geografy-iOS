import Foundation

public struct IndependenceTimelineService {
    public init() {}
    public var events: [IndependenceEvent] { independenceEvents }

    public func events(for era: IndependenceEra) -> [IndependenceEvent] {
        independenceEvents.filter { era.contains(year: $0.year) }
            .sorted { $0.year < $1.year }
    }

    public func events(independenceFrom country: String) -> [IndependenceEvent] {
        guard !country.isEmpty else { return independenceEvents.sorted { $0.year < $1.year } }
        return independenceEvents.filter { $0.independenceFrom == country }
            .sorted { $0.year < $1.year }
    }

    public var uniqueColonizers: [String] {
        let all = Set(independenceEvents.map(\.independenceFrom))
        return all.sorted()
    }
}

public enum IndependenceEra: String, Sendable, CaseIterable, Identifiable {
    case preMoM = "Pre-1800"
    case nineteenthCentury = "1800s"
    case earlyTwentieth = "1900–1950"
    case lateTwentieth = "1950–2000"
    case modern = "2000+"

    public var id: String { rawValue }

    public func contains(year: Int) -> Bool {
        switch self {
        case .preMoM: year < 1_800
        case .nineteenthCentury: year >= 1_800 && year < 1_900
        case .earlyTwentieth: year >= 1_900 && year < 1_950
        case .lateTwentieth: year >= 1_950 && year < 2_000
        case .modern: year >= 2_000
        }
    }
}
