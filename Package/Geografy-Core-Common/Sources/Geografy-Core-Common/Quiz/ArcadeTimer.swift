import Foundation

public enum ArcadeTimer: String, CaseIterable, Identifiable, Codable, Sendable {
    case sixty = "60s"
    case ninety = "90s"
    case none = "No Timer"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .sixty: "timer"
        case .ninety: "timer"
        case .none: "infinity"
        }
    }

    public var duration: TimeInterval? {
        switch self {
        case .sixty: 60
        case .ninety: 90
        case .none: nil
        }
    }
}
