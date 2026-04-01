import Foundation

struct Language: Identifiable {
    let id: String // ISO 639-1 code
    let name: String
    let nativeName: String
    let speakerCount: Int // millions
    let countries: [String] // country codes where official
    let family: String
    let script: String
    let funFact: String
}
