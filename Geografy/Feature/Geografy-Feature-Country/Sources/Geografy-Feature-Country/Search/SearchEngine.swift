import Foundation
import Geografy_Core_Common

/// Finds countries, capitals, and organizations for a query, best matches first.
///
/// Every name is folded once, when the engine is made, so a keystroke compares the query against ready text
/// instead of folding hundreds of names again. Keep one engine for as long as the countries don't change.
struct SearchEngine {
    // MARK: - Properties
    private let countries: [(country: Country, name: String)]
    private let capitals: [(country: Country, name: String, folded: String)]
    private let organizations: [(organization: Organization, names: [String])]

    /// How many of each kind "All" shows before the person narrows the scope.
    private static let allScopeLimit = 5

    // MARK: - Init
    init(countries: [Country], organizations: [Organization]) {
        self.countries = countries.map { ($0, Self.fold($0.name)) }
        self.capitals = countries.flatMap { country in
            country.allCapitals.map { (country, $0.name, Self.fold($0.name)) }
        }
        self.organizations = organizations.map { organization in
            (organization, [organization.displayName, organization.fullName].map(Self.fold))
        }
    }

    // MARK: - Search
    func results(for query: String, scope: SearchScope) -> SearchResults {
        let foldedQuery = Self.fold(query.trimmingCharacters(in: .whitespacesAndNewlines))
        guard !foldedQuery.isEmpty else { return .empty }

        let groups = [
            Group(id: "countries", title: "Countries", scope: .countries, matches: countryMatches(for: foldedQuery)),
            Group(id: "capitals", title: "Capitals", scope: .capitals, matches: capitalMatches(for: foldedQuery)),
            Group(
                id: "organizations",
                title: "Organizations",
                scope: .organizations,
                matches: organizationMatches(for: foldedQuery)
            ),
        ]
        .filter { scope == .all || $0.scope == scope }

        let topHit = scope == .all ? Self.topHit(in: groups) : nil
        let sections = groups.compactMap { group -> SearchResultSection? in
            let rows = group.matches
                .map(\.row)
                .filter { $0 != topHit }
                .prefix(scope == .all ? Self.allScopeLimit : .max)
            return rows.isEmpty ? nil : SearchResultSection(id: group.id, title: group.title, rows: Array(rows))
        }
        return SearchResults(topHit: topHit, sections: sections)
    }
}

// MARK: - Matching
private extension SearchEngine {
    struct Match {
        let row: SearchRow
        let rank: Rank
        let name: String
    }

    struct Group {
        let id: String
        let title: String
        let scope: SearchScope
        let matches: [Match]
    }

    /// Lower is better.
    enum Rank: Int, Comparable {
        case exact
        case prefix
        case wordPrefix
        case contains

        static func < (lhs: Rank, rhs: Rank) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    func countryMatches(for foldedQuery: String) -> [Match] {
        Self.sorted(
            countries.compactMap { entry in
                Self.rank(ofFolded: entry.name, for: foldedQuery).map {
                    Match(row: .country(entry.country), rank: $0, name: entry.country.name)
                }
            }
        )
    }

    func capitalMatches(for foldedQuery: String) -> [Match] {
        Self.sorted(
            capitals.compactMap { entry in
                Self.rank(ofFolded: entry.folded, for: foldedQuery).map {
                    Match(row: .capital(country: entry.country, capitalName: entry.name), rank: $0, name: entry.name)
                }
            }
        )
    }

    func organizationMatches(for foldedQuery: String) -> [Match] {
        Self.sorted(
            organizations.compactMap { entry in
                let ranks = entry.names.compactMap { Self.rank(ofFolded: $0, for: foldedQuery) }
                return ranks.min().map {
                    Match(row: .organization(entry.organization), rank: $0, name: entry.organization.fullName)
                }
            }
        )
    }

    /// The single best exact or prefix match across every kind; earlier kinds win ties.
    static func topHit(in groups: [Group]) -> SearchRow? {
        groups
            .compactMap(\.matches.first)
            .filter { $0.rank <= .prefix }
            .min { $0.rank < $1.rank }?
            .row
    }

    static func sorted(_ matches: [Match]) -> [Match] {
        matches.sorted {
            $0.rank != $1.rank
                ? $0.rank < $1.rank
                : $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }

    static func rank(ofFolded folded: String, for foldedQuery: String) -> Rank? {
        if folded == foldedQuery { return .exact }
        if folded.hasPrefix(foldedQuery) { return .prefix }
        let words = folded.split { !$0.isLetter && !$0.isNumber }
        if words.contains(where: { $0.hasPrefix(foldedQuery) }) { return .wordPrefix }
        if folded.contains(foldedQuery) { return .contains }
        return nil
    }

    static func fold(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
    }
}
