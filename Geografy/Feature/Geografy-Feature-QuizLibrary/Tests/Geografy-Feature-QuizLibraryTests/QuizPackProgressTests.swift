import Foundation
import Geografy_Core_Common
@testable import Geografy_Feature_QuizLibrary
import Testing

@Suite("Quiz pack progress", .serialized)
@MainActor
struct QuizPackProgressTests {
    private static let pack = QuizPack(
        id: "test-pack",
        name: "Test Pack",
        description: "",
        icon: "star",
        category: .capitals,
        levels: [
            QuizPackLevel(id: "test-1", name: "Level 1", levelIndex: 1, questionCount: 5, countryCodes: ["FR", "DE"]),
            QuizPackLevel(id: "test-2", name: "Level 2", levelIndex: 2, questionCount: 5, countryCodes: ["JP", "KE"]),
        ],
        prerequisitePackID: nil
    )

    @Test("Under half right neither earns stars nor counts the level as done")
    func failingDoesNotPass() {
        let service = isolatedService()
        service.recordCompletion(levelID: "test-1", accuracy: 0.4)

        #expect(service.progress(for: "test-1") == nil)
        #expect(service.completedLevelCount(for: Self.pack) == 0)
    }

    @Test("A pass records its stars and keeps the best score")
    func passKeepsBest() {
        let service = isolatedService()
        service.recordCompletion(levelID: "test-1", accuracy: 0.75)
        service.recordCompletion(levelID: "test-1", accuracy: 0.6)

        #expect(service.stars(for: "test-1") == 2)
        #expect(service.completedLevelCount(for: Self.pack) == 1)
    }

    @Test("A pack with no levels yet is not done")
    func emptyPackIsNotDone() {
        let service = isolatedService()
        let empty = QuizPack(
            id: "empty",
            name: "Empty",
            description: "",
            icon: "star",
            category: .flags,
            levels: [],
            prerequisitePackID: nil
        )

        #expect(!service.isPackCompleted(empty))
    }

    @Test("A finished quiz announces its accuracy under its own id")
    func finishAnnouncesAccuracy() async {
        let configuration = QuizConfiguration.quickPlay(.capitalQuiz)
        await confirmation { finished in
            let observer = NotificationCenter.default.addObserver(
                forName: QuizConfiguration.finishedNotification,
                object: nil,
                queue: nil
            ) { notification in
                if notification.object as? UUID == configuration.id,
                   notification.userInfo?[QuizConfiguration.accuracyKey] as? Double == 0.8 {
                    finished()
                }
            }
            configuration.announceFinished(accuracy: 0.8)
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// A service for a throwaway user, so tests never see or touch real progress.
    private func isolatedService() -> QuizPackService {
        UserScope.activate("tests-\(UUID().uuidString)")
        return QuizPackService()
    }
}
