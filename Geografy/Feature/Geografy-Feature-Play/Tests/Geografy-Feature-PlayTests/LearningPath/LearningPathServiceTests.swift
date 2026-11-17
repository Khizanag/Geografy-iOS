import Foundation
import Geografy_Core_Common
@testable import Geografy_Feature_Play
import Testing

extension UserScopedTests {
    @Suite("LearningPathService", .serialized)
    struct LearningPathServiceTests {
        @Test("Only the first module starts unlocked")
        func firstModuleUnlocked() {
            UserScope.activate(UUID().uuidString)
            let service = LearningPathService()

            #expect(service.modules.first?.isUnlocked == true)
            #expect(service.modules.dropFirst().allSatisfy { !$0.isUnlocked })
        }

        @Test("A lesson counts as new only the first time, so it's rewarded once")
        func lessonRewardedOnce() throws {
            UserScope.activate(UUID().uuidString)
            let service = LearningPathService()
            let module = try #require(service.modules.first)
            let lesson = try #require(module.lessons.first)

            #expect(service.completeLesson(moduleID: module.id, lessonID: lesson.id))
            #expect(!service.completeLesson(moduleID: module.id, lessonID: lesson.id))
            #expect(!service.completeLesson(moduleID: module.id, lessonID: "missing"))
        }

        @Test("Finishing a module unlocks the next one")
        func finishingUnlocksNext() throws {
            UserScope.activate(UUID().uuidString)
            let service = LearningPathService()
            let module = try #require(service.modules.first)

            for lesson in module.lessons {
                service.completeLesson(moduleID: module.id, lessonID: lesson.id)
            }

            #expect(service.modules.first?.isCompleted == true)
            #expect(service.modules.dropFirst().first?.isUnlocked == true)
        }

        @Test("Progress is saved per user and comes back on reload")
        func progressPersistsPerUser() throws {
            let learner = UUID().uuidString
            UserScope.activate(learner)
            let service = LearningPathService()
            let module = try #require(service.modules.first)
            let lesson = try #require(module.lessons.first)
            service.completeLesson(moduleID: module.id, lessonID: lesson.id)

            UserScope.activate(UUID().uuidString)
            service.reload()
            #expect(service.modules.first?.completedCount == 0)

            UserScope.activate(learner)
            service.reload()
            #expect(service.modules.first?.completedCount == 1)
        }
    }
}
