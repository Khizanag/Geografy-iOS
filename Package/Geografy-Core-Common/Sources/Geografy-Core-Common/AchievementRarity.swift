import SwiftUI

public enum AchievementRarity: String, CaseIterable, Codable, Sendable {
    case common
    case rare
    case epic
    case legendary
}

// MARK: - Display
extension AchievementRarity {
    public var displayName: String {
        switch self {
        case .common: "Common"
        case .rare: "Rare"
        case .epic: "Epic"
        case .legendary: "Legendary"
        }
    }

    public var borderColor: Color {
        switch self {
        case .common: Color(hex: "CD7F32")
        case .rare: Color(hex: "C0C0C0")
        case .epic: Color(hex: "FFD700")
        case .legendary: Color(hex: "B9F2FF")
        }
    }

    public var borderGradient: LinearGradient {
        switch self {
        case .common:
            LinearGradient(
                colors: [Color(hex: "CD7F32"), Color(hex: "A0522D")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .rare:
            LinearGradient(
                colors: [Color(hex: "C0C0C0"), Color(hex: "E8E8E8")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .epic:
            LinearGradient(
                colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .legendary:
            LinearGradient(
                colors: [
                    Color(hex: "B9F2FF"),
                    Color(hex: "E0FFFF"),
                    Color(hex: "87CEEB"),
                    Color(hex: "B9F2FF"),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    public var backgroundOpacity: Double {
        switch self {
        case .common: 0.08
        case .rare: 0.10
        case .epic: 0.12
        case .legendary: 0.16
        }
    }

    public var borderWidth: CGFloat {
        switch self {
        case .common: 1.5
        case .rare: 1.5
        case .epic: 2
        case .legendary: 2.5
        }
    }

    public var sortOrder: Int {
        switch self {
        case .common: 0
        case .rare: 1
        case .epic: 2
        case .legendary: 3
        }
    }
}
