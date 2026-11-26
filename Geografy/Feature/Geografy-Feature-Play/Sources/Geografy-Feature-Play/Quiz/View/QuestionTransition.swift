import SwiftUI

extension AnyTransition {
    /// One question giving way to the next: it slides out to the leading edge as the next slides in from the
    /// trailing one. Only the question moves; the answers stay in their places and rise in anew (`QuizOptionList`),
    /// so their glass never travels across the screen. Under Reduce Motion it fades.
    static func nextQuestion(reduceMotion: Bool) -> AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
