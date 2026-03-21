import Foundation
import Observation
import SwiftData

@Observable
final class DatabaseManager {
    let container: ModelContainer

    @MainActor
    var mainContext: ModelContext { container.mainContext }

    init(inMemory: Bool = false) {
        let schema = Schema([
            UserProfile.self,
            XPRecord.self,
            QuizHistoryRecord.self,
            UnlockedAchievement.self,
            StreakRecord.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        // swiftlint:disable:next force_try
        container = try! ModelContainer(for: schema, configurations: [config])
    }
}
