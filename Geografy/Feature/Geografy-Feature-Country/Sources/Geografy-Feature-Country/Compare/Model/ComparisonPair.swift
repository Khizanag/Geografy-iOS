import Geografy_Core_Common

/// Two countries compared together, saved so a recent comparison can be reopened.
struct ComparisonPair: Identifiable, Codable, Equatable {
    let leftCode: String
    let leftName: String
    let rightCode: String
    let rightName: String

    var id: String { "\(leftCode)-\(rightCode)" }

    init(left: Country, right: Country) {
        leftCode = left.code
        leftName = left.name
        rightCode = right.code
        rightName = right.name
    }

    /// The same two countries, in either order.
    func matches(_ other: ComparisonPair) -> Bool {
        Set([leftCode, rightCode]) == Set([other.leftCode, other.rightCode])
    }
}
