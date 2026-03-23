import Foundation

struct WorldRecord: Identifiable {
    let id = UUID()
    let category: WorldRecordCategory
    let title: String
    let countryCode: String
    let countryName: String
    let value: String
    let unit: String
    let description: String
}
