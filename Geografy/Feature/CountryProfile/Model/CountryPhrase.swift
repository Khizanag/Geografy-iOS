import Foundation

struct CountryPhrase: Codable, Identifiable {
    var id: String { english }

    let english: String
    let local: String
    let pronunciation: String
}
