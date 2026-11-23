import Foundation
import Geografy_Core_Common
import Geografy_Core_Navigation
import SwiftUI

/// Screens only the Play feature opens.
enum PlayLocalRoute: Route {
    case customQuizShare(CustomQuiz)
    case dailyChallengeResult(
        score: Int,
        maxScore: Int,
        challengeType: DailyChallengeType,
        timeSpent: TimeInterval,
        streak: Int
    )
    case flashcardSession(deck: FlashcardDeck, cards: [FlashcardItem])
    case learningModule(LearningModule)
    case lesson(LearningModule, Lesson)
    case pinDropGame(PinDropConfiguration)
    case quizPackDetail(packID: String)
    case speedRunSession(region: QuizRegion)
    case wordSearchGame(WordSearchTheme)
}

public extension RouteRegistry {
    /// Registers the screens of the Play feature's routes.
    mutating func registerPlayScreens() {
        registerPlayRoutes()
        registerPlayLocalRoutes()
    }
}

// MARK: - Registration
private extension RouteRegistry {
    mutating func registerPlayRoutes() {
        register(PlayRoute.self) { route in
            switch route {
            case .dailyChallenge: DailyChallengeScreen()
            case .learningPath: LearningPathScreen()
            case .mapPuzzle(let continent): MapPuzzleSetupScreen(continent: continent)
            case .mapPuzzleGame(let continent): MapPuzzleScreen(continent: continent)
            case .multiplayer: LocalMultiplayerEntryScreen()
            case .pinDrop: PinDropSetupScreen()
            case .quizLibrary(let tab): QuizLibraryScreen(tab: tab)
            case .quizSession(let configuration): QuizSessionScreen(configuration: configuration)
            case .quizSetup: QuizSetupScreen()
            case .speedRunSetup: SpeedRunSetupScreen()
            case .srsStudy: SRSStudyScreen()
            case .wordSearch: WordSearchScreen()
            }
        }
    }

    mutating func registerPlayLocalRoutes() {
        register(PlayLocalRoute.self) { route in
            switch route {
            case .customQuizShare(let quiz): CustomQuizShareScreen(quiz: quiz)
            case let .dailyChallengeResult(score, maxScore, type, time, streak):
                DailyChallengeResultView(
                    score: score,
                    maxScore: maxScore,
                    challengeType: type,
                    timeSpent: time,
                    streak: streak
                )
            case let .flashcardSession(deck, cards): FlashcardSessionScreen(deck: deck, cards: cards)
            case .learningModule(let module): ModuleLessonsScreen(module: module)
            case let .lesson(module, lesson): LessonScreen(module: module, lesson: lesson)
            case .pinDropGame(let configuration): PinDropScreen(configuration: configuration)
            case .quizPackDetail(let packID): QuizPackDetailScreen(packID: packID)
            case .speedRunSession(let region): SpeedRunSessionScreen(region: region)
            case .wordSearchGame(let theme): WordSearchGameScreen(theme: theme)
            }
        }
    }
}
