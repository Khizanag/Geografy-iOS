import Geografy_Core_Common

/// Screens of the Play feature that other features open.
public enum PlayRoute: Route {
    case dailyChallenge
    case learningPath
    /// Map Puzzle's setup, with `continent` chosen when given; nil keeps the player's last choice.
    case mapPuzzle(continent: Country.Continent? = nil)
    /// A Map Puzzle on one continent, or on the whole world when it's nil.
    case mapPuzzleGame(continent: Country.Continent?)
    case multiplayer
    case pinDrop
    case quizLibrary(QuizLibraryTab)
    case quizSession(QuizConfiguration)
    /// The quiz setup, with `type` chosen when given; nil keeps the player's last choice.
    case quizSetup(type: QuizType? = nil)
    case speedRunSetup
    case srsStudy
    case wordSearch
}
