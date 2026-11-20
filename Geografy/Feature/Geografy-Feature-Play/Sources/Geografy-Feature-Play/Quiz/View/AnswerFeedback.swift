import Geografy_Core_DesignSystem
import SwiftUI

/// What every game does the moment an answer is checked: the sound, the haptic, and the spoken result.
/// One place, so a right or wrong answer feels the same in every game.
@MainActor
struct AnswerFeedback {
    // MARK: - Properties
    /// How long the right answer stays revealed before the next question comes in.
    static let revealDuration: Duration = .seconds(1.3)

    let soundService: SoundService
    let hapticsService: HapticsService

    // MARK: - Actions
    /// - Parameter announcement: What VoiceOver says; defaults to "Correct." or "Incorrect."
    func play(isCorrect: Bool, announcement: String? = nil) {
        soundService.play(isCorrect ? .correct : .wrong)
        hapticsService.notification(isCorrect ? .success : .error)
        let spoken = announcement ?? String(localized: isCorrect ? "Correct." : "Incorrect.", bundle: .module)
        AccessibilityNotification.Announcement(spoken).post()
    }

    /// The spoken result of a wrong answer, naming the right one.
    static func incorrectAnnouncement(answer: String) -> String {
        String(localized: "Incorrect. The answer is \(answer).", bundle: .module)
    }
}
