import Geografy_Core_Common
import SwiftUI

extension AchievementCategory {
    public var themeColor: Color {
        switch self {
        case .explorer: DesignSystem.Color.indigo
        case .quizExpert: DesignSystem.Color.blue
        case .streak: DesignSystem.Color.orange
        case .continental: DesignSystem.Color.teal
        case .flashcard: DesignSystem.Color.purple
        case .speed: DesignSystem.Color.pink
        case .perfectScore: DesignSystem.Color.success
        case .travel: DesignSystem.Color.teal
        case .knowledge: DesignSystem.Color.warning
        case .social: DesignSystem.Color.pink
        }
    }
}
