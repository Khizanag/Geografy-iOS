import Foundation

/// Feature-specific source of quiz questions.
///
/// Each quiz feature owns its own `Question` type (flag → country, progressive
/// clues, landmark-image pair, …). The kernel only cares that the provider can
/// enumerate them in order and report when it is exhausted.
///
/// Implementations should be `Sendable` so they compose safely with
/// `@MainActor`-bound ``QuizSession`` usage.
public protocol QuestionProvider: Sendable {
    associatedtype Question: Sendable

    /// Total number of questions this provider can serve. Callers size the
    /// session around this value.
    var total: Int { get async }

    /// Produce the next question, or `nil` when the stream is exhausted.
    /// Implementations may be lazy — e.g. streaming a large pack.
    func next() async -> Question?

    /// Restart the stream from the beginning.
    func reset() async
}
