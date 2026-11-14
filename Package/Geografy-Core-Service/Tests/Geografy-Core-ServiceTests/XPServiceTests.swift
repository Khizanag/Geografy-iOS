import Combine
import Foundation
@testable import Geografy_Core_Service
import Testing

@MainActor
@Suite("XPService")
struct XPServiceTests {
    @Test("Awards add up to the same total the stored records give")
    func awardsMatchStoredTotal() {
        let database = DatabaseManager(inMemory: true)
        let service = XPService(db: database, userID: UUID().uuidString)
        service.refreshXP()

        service.award(30, source: .quizCompletedEasy)
        service.award(45, source: .dailyLogin)
        let runningTotal = service.totalXP
        service.refreshXP()

        #expect(runningTotal == 75)
        #expect(service.totalXP == runningTotal)
    }

    @Test("Crossing a level threshold announces the new level")
    func levelUpIsAnnounced() {
        let database = DatabaseManager(inMemory: true)
        let service = XPService(db: database, userID: UUID().uuidString)
        service.refreshXP()
        var announcedLevels: [Int] = []
        let subscription = service.levelUpPublisher.sink { announcedLevels.append($0.level) }

        service.award(service.currentLevel.maxXP, source: .quizCompletedEasy)

        #expect(announcedLevels == [service.currentLevel.level])
        subscription.cancel()
    }
}
