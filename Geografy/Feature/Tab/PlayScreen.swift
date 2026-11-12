import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_DailyChallenge
import Geografy_Feature_Flashcard
import SwiftUI

/// The Play tab: today's challenge on top, then every quiz and game.
struct PlayScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(XPService.self) private var xpService
    @Environment(FlashcardService.self) private var flashcardService

    @State private var dailyChallengeService: DailyChallengeService?

    // MARK: - Body
    var body: some View {
        HubScreen(title: "Play", sections: Self.sections) {
            DailyActionCard(
                dailyChallengeCompleted: dailyChallengeService?.hasCompletedToday ?? false,
                srsCardsDue: dueReviewCount,
                onDailyChallenge: { coordinator.push(.dailyChallenge) },
                onReviewCards: { coordinator.push(.srsStudy) },
                onStartQuiz: { coordinator.push(.quizSetup) }
            )
        }
        .task { await loadDailyChallenge() }
    }
}

// MARK: - Sections
private extension PlayScreen {
    static let sections = [
        HubSection(title: "Quick Play", items: [.quiz, .trueOrFalse, .neighbors, .mysteryCountry]),
        HubSection(title: "Games", items: [.speedRun, .quizPacks, .multiplayer, .mapPuzzle, .wordSearch]),
    ]
}

// MARK: - Data
private extension PlayScreen {
    var dueReviewCount: Int {
        let allCards = countryDataService.countries.map {
            FlashcardItem.make(from: $0, type: .countryToCapital)
        }
        return flashcardService.dueCards(from: allCards).count
    }

    func loadDailyChallenge() async {
        let service = DailyChallengeService(
            countryDataService: countryDataService,
            userID: xpService.currentUserID
        )
        await service.loadChallenge()
        dailyChallengeService = service
    }
}
