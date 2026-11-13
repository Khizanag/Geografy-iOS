import Foundation
@testable import Geografy_Core_Service
import Testing

@MainActor
@Suite("AchievementService")
struct AchievementServiceTests {
    @Test("One user's progress doesn't show for another user")
    func progressIsPerUser() {
        let firstUser = UUID().uuidString
        let secondUser = UUID().uuidString
        let service = Self.makeService(userID: firstUser)
        service.checkExplorerAchievements(totalExplored: 3)

        service.switchUser(id: secondUser)

        #expect(service.progress(for: "explorer_5").currentValue == 0)
    }

    @Test("Reaching a target unlocks it for the current user even if another user unlocked it first")
    func unlockIsPerUser() {
        let firstUser = UUID().uuidString
        let secondUser = UUID().uuidString
        let service = Self.makeService(userID: firstUser)
        service.checkExplorerAchievements(totalExplored: 5)
        service.switchUser(id: secondUser)

        service.checkExplorerAchievements(totalExplored: 5)

        #expect(service.isUnlocked("explorer_5"))
    }

    @Test("Progress below the target stays locked")
    func belowTargetStaysLocked() {
        let service = Self.makeService(userID: UUID().uuidString)

        service.checkExplorerAchievements(totalExplored: 2)

        #expect(service.progress(for: "explorer_5").currentValue == 2)
        #expect(!service.isUnlocked("explorer_5"))
    }
}

// MARK: - Helpers
private extension AchievementServiceTests {
    static func makeService(userID: String) -> AchievementService {
        let database = DatabaseManager(inMemory: true)
        let xpService = XPService(db: database, userID: userID)
        let service = AchievementService(db: database, xpService: xpService, userID: userID)
        service.switchUser(id: userID)
        return service
    }
}
