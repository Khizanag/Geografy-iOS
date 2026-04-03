import Foundation

public enum QuestionCount: Int, CaseIterable, Identifiable, Sendable {
    case five = 5
    case ten = 10
    case twenty = 20
    case thirty = 30
    case fifty = 50

    public var id: Int { rawValue }

    public var displayName: String {
        "\(rawValue)"
    }
}
