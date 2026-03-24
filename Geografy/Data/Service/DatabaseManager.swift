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
            FavoriteEntry.self,
            QuizHistoryRecord.self,
            StreakRecord.self,
            UnlockedAchievement.self,
            UserProfile.self,
            XPRecord.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
}
