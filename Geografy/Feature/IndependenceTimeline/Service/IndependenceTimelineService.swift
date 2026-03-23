import Foundation

struct IndependenceTimelineService {
    var events: [IndependenceEvent] { independenceEvents }

    func events(for era: IndependenceEra) -> [IndependenceEvent] {
        independenceEvents.filter { era.contains(year: $0.year) }
            .sorted { $0.year < $1.year }
    }

    func events(independenceFrom country: String) -> [IndependenceEvent] {
        guard !country.isEmpty else { return independenceEvents.sorted { $0.year < $1.year } }
        return independenceEvents.filter { $0.independenceFrom == country }
            .sorted { $0.year < $1.year }
    }

    var uniqueColonizers: [String] {
        let all = Set(independenceEvents.map(\.independenceFrom))
        return all.sorted()
    }
}

enum IndependenceEra: String, CaseIterable, Identifiable {
    case preMoM = "Pre-1800"
    case nineteenthCentury = "1800s"
    case earlyTwentieth = "1900–1950"
    case lateTwentieth = "1950–2000"
    case modern = "2000+"

    var id: String { rawValue }

    func contains(year: Int) -> Bool {
        switch self {
        case .preMoM: year < 1800
        case .nineteenthCentury: year >= 1800 && year < 1900
        case .earlyTwentieth: year >= 1900 && year < 1950
        case .lateTwentieth: year >= 1950 && year < 2000
        case .modern: year >= 2000
        }
    }
}
