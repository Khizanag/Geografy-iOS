/// A multiplayer match as a game's own screen sees it: how the other player is doing, and where to report this
/// player's rounds. Every game plays a match through its normal screen with one of these; on its own, it has none.
@MainActor
protocol LocalMatch: AnyObject {
    var opponentName: String { get }
    var opponentScore: Int { get }
    /// Whether the other player has played this round, such as locking in a pin or answering a question.
    func hasOpponentScored(round: Int) -> Bool
    /// This player finished a round, worth `points`: a pin's score, 1 for a right answer, 1 for a word or a country.
    func didScore(round: Int, points: Int)
    /// This player has played every round; a race ends now, the other games once both players have.
    func didFinishRounds()
}
