import Geografy_Core_DesignSystem
import SwiftUI

/// Which of the two countries a value belongs to. Each side keeps one color across slots, bars and badges.
enum CompareSide {
    case left
    case right

    var color: Color {
        switch self {
        case .left: DesignSystem.Color.blue
        case .right: DesignSystem.Color.orange
        }
    }

    var title: String {
        switch self {
        case .left: "First country"
        case .right: "Second country"
        }
    }
}

extension CompareSide: Identifiable {
    var id: Self { self }
}
