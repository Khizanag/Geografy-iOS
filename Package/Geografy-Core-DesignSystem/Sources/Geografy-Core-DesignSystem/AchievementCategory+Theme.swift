import Geografy_Core_Common
import SwiftUI

extension AchievementCategory {
    public var themeColor: Color {
        switch self {
        case .explorer: DesignSystem.Color.blue
        case .quizMaster: DesignSystem.Color.purple
        case .streak: DesignSystem.Color.error
        case .continental: DesignSystem.Color.ocean
        case .flashcard: DesignSystem.Color.indigo
        case .speed: DesignSystem.Color.orange
        case .perfectScore: DesignSystem.Color.success
        case .travel: DesignSystem.Color.accent
        case .knowledge: DesignSystem.Color.warning
        case .social: DesignSystem.Color.accent
        }
    }
}
