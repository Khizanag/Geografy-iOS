import Geografy_Core_Common
import Geografy_Core_Service
import SwiftUI

public struct AchievementDetailView: View {
    // MARK: - Properties
    @Environment(AchievementService.self) private var achievementService

    public let definition: AchievementDefinition

    // MARK: - Init
    public init(definition: AchievementDefinition) {
        self.definition = definition
    }

    // MARK: - Body
    public var body: some View {
        AchievementDetailSheet(
            definition: definition,
            isUnlocked: achievementService.isUnlocked(definition.id),
            progress: achievementService.progress(for: definition.id),
            isPinned: achievementService.isPinned(definition.id),
            canPin: achievementService.canPinMore,
            onTogglePin: { achievementService.togglePin(definition.id) }
        )
    }
}
