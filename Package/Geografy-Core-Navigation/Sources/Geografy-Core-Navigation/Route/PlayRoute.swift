import Geografy_Core_Common

/// Screens of the Play feature that other features open.
public enum PlayRoute: Route {
    case dailyChallenge
    case learningPath
    case mapPuzzle
    case multiplayer
    case pinDrop
    case quizLibrary(QuizLibraryTab)
    case quizSession(QuizConfiguration)
    case quizSetup
    case speedRunSetup
    case srsStudy
    case wordSearch
}
