import Foundation

public struct Language: Identifiable, Hashable {
    public let id: String // ISO 639-1 code
    public let name: String
    public let nativeName: String
    public let speakerCount: Int // millions
    public let countries: [String] // country codes where official
    public let family: String
    public let script: String
    public let funFact: String
}
