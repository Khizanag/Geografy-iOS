import Foundation

public enum QuizGameMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case standard = "Standard"
    case arcade = "Arcade"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .standard: "list.number"
        case .arcade: "bolt.fill"
        }
    }

    public var description: String {
        switch self {
        case .standard: "Fixed questions, your pace"
        case .arcade: "3 lives, endless questions"
        }
    }
}
