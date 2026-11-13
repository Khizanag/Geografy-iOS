import Foundation
import Geografy_Core_Common

/// Finds countries, capitals, and organizations for a query, best matches first.
struct SearchEngine {
    // MARK: - Properties
    let countries: [Country]
    let organizations: [Organization]

    /// How many of each kind "All" shows before the person narrows the scope.
    private static let allScopeLimit = 5

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
            countries.compactMap { country in
                Self.rank(of: country.name, for: foldedQuery).map {
                    Match(row: .country(country), rank: $0, name: country.name)
                }
            }
        )
    }

    func capitalMatches(for foldedQuery: String) -> [Match] {
        Self.sorted(
            countries.flatMap { country in
                country.allCapitals.compactMap { capital in
                    Self.rank(of: capital.name, for: foldedQuery).map {
                        Match(row: .capital(country: country, capitalName: capital.name), rank: $0, name: capital.name)
                    }
                }
            }
        )
    }

    func organizationMatches(for foldedQuery: String) -> [Match] {
        Self.sorted(
            organizations.compactMap { organization in
                let ranks = [organization.displayName, organization.fullName].compactMap {
                    Self.rank(of: $0, for: foldedQuery)
                }
                return ranks.min().map {
                    Match(row: .organization(organization), rank: $0, name: organization.fullName)
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

    static func rank(of text: String, for foldedQuery: String) -> Rank? {
        let folded = fold(text)
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
