import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import Geografy_Feature_Play
import SwiftUI

/// The Play tab: today's challenge on top, then the study tools, then every game.
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
                srsCardsDue: flashcardService.dueCount(of: .countryToCapital, in: countryDataService.countries),
                onDailyChallenge: { coordinator.push(PlayRoute.dailyChallenge) },
                onReviewCards: { coordinator.push(PlayRoute.srsStudy) },
                onStartQuiz: { coordinator.push(PlayRoute.quizSetup) }
            )
        }
        .task { await loadDailyChallenge() }
    }
}

// MARK: - Sections
private extension PlayScreen {
    static let sections = [
        HubSection(title: "Study", items: [.learningPath, .srsStudy]),
        HubSection(
            title: "Games",
            items: [.quiz, .mapPuzzle, .pinDrop, .speedRun, .wordSearch, .quizPacks, .multiplayer]
        ),
    ]
}

// MARK: - Data
private extension PlayScreen {
    // Runs on every appearance so a challenge finished elsewhere shows as done; the refresh is cheap.
    func loadDailyChallenge() async {
        let service = DailyChallengeService.service(
            reusing: dailyChallengeService,
            countryDataService: countryDataService,
            userID: xpService.currentUserID
        )
        await service.loadChallenge()
        if dailyChallengeService !== service {
            dailyChallengeService = service
        }
    }
}
