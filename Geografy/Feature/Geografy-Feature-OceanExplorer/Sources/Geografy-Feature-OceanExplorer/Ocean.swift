import Foundation

struct Ocean: Identifiable {
    let id: String
    let name: String
    let area: Double // km²
    let averageDepth: Double // meters
    let maxDepth: Double // meters
    let borderingContinents: [String]
    let funFact: String
    let icon: String // SF Symbol
    let isOcean: Bool
}
