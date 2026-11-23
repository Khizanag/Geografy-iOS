import Geografy_Core_DesignSystem
import SwiftUI

/// What every game does the moment an answer is checked: the sound and the spoken result now, and the haptic from
/// the view through `answerHaptic(_:)`. One place, so a right or wrong answer feels the same in every game.
@MainActor
struct AnswerFeedback {
    // MARK: - Properties
    /// How long the right answer stays revealed before the next question comes in.
    static let revealDuration: Duration = .seconds(1.3)

    let soundService: SoundService

    // MARK: - Actions
    /// Plays the sound and posts the spoken result, and returns the answer for the screen to keep, so its
    /// `answerHaptic(_:)` plays success or error.
    /// - Parameter announcement: What VoiceOver says; defaults to "Correct." or "Incorrect."
    func play(isCorrect: Bool, announcement: String? = nil) -> CheckedAnswer {
        soundService.play(isCorrect ? .correct : .wrong)
        let spoken = announcement ?? String(localized: isCorrect ? "Correct." : "Incorrect.", bundle: .module)
        AccessibilityNotification.Announcement(spoken).post()
        return CheckedAnswer(isCorrect: isCorrect)
    }

    /// The spoken result of a wrong answer, naming the right one.
    static func incorrectAnnouncement(answer: String) -> String {
        String(localized: "Incorrect. The answer is \(answer).", bundle: .module)
    }
}

// MARK: - Checked Answer
/// One checked answer. Each is new, so two right answers in a row each play their haptic.
struct CheckedAnswer: Equatable {
    let id = UUID()
    let isCorrect: Bool
}

// MARK: - Haptic
extension View {
    /// Success for a right answer and error for a wrong one, each time a new answer is checked.
    func answerHaptic(_ answer: CheckedAnswer?) -> some View {
        haptic(trigger: answer) { _, newAnswer in
            newAnswer.map { $0.isCorrect ? .success : .error }
        }
    }
}
