import Foundation
import Geografy_Core_Common
import Observation
import SwiftData

@Observable
public final class DatabaseManager {
    public let container: ModelContainer

    @MainActor
    public var mainContext: ModelContext { container.mainContext }

    public init(inMemory: Bool = false) {
        let schema = Schema([
            CollectionItem.self,
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
