import SwiftUI

/// One of the two things a pair screen (Compare, Distance, Currency) works with.
/// Each side keeps one color across its slot, bars and badges, so values read as "whose" at a glance.
public enum PairSide: Identifiable, Sendable {
    case left
    case right

    public var id: Self { self }

    public var color: Color {
        switch self {
        case .left: DesignSystem.Color.blue
        case .right: DesignSystem.Color.orange
        }
    }

    public var other: PairSide {
        switch self {
        case .left: .right
        case .right: .left
        }
    }
}
