import Foundation

/// Supplementary capitals data for countries missing `capitals` in countries.json.
/// Applied during country loading to ensure all multi-capital countries are represented.
enum MultipleCapitalsData {
    static let data: [String: [Country.Capital]] = [
        "BJ": [
            Country.Capital(name: "Porto-Novo", role: "Legislative"),
            Country.Capital(name: "Cotonou", role: "Seat of Government"),
        ],
        "IL": [
            Country.Capital(name: "Jerusalem", role: "Declared"),
            Country.Capital(name: "Tel Aviv", role: "Diplomatic"),
        ],
    ]
}
