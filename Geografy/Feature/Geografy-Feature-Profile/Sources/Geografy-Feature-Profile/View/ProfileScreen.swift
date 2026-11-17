#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftData
import SwiftUI

public struct ProfileScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) var coordinator
    @Environment(AuthService.self) var authService
    @Environment(XPService.self) var xpService
    @Environment(StreakService.self) var streakService
    @Environment(AchievementService.self) var achievementService
    @Environment(TravelService.self) var travelService
    @Environment(ExplorationService.self) var explorationService
    @Environment(DatabaseManager.self) var database
    @Environment(HapticsService.self) var hapticsService
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @State var recentQuizzes: [QuizHistoryRecord] = []
    @State var quizTotals: QuizTotals?
    @State var statistics: UserStatistics?
    @State var showDeleteAlert = false
    @State var showSignOutAlert = false
    /// Wide enough for a two-line achievement name, growing with the text size.
    @ScaledMetric(relativeTo: .caption2) var achievementTitleWidth: CGFloat = 84
    @State var selectedAchievement: AchievementDefinition?

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .confirmationDialog("Sign Out", isPresented: $showSignOutAlert, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) { authService.signOut() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You can sign back in anytime to restore your progress.")
            }
            .alert("Delete Account", isPresented: $showDeleteAlert) {
                deleteAlertActions
            } message: {
                deleteAlertMessage
            }
            .onAppear { refreshQuizData() }
    }
}

// MARK: - Scroll Content
private extension ProfileScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            scrollInnerContent
        }
    }

    var scrollInnerContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            if authService.isGuest {
                guestBanner
                    .phaseEntrance(index: 0)
            }
            headerSection
                .phaseEntrance(index: 1)
            levelProgressSection
                .phaseEntrance(index: 2)
            statsGridSection
                .phaseEntrance(index: 3)
            weeklyActivitySection
                .phaseEntrance(index: 4)
            achievementsPreviewSection
                .phaseEntrance(index: 5)
            if !recentQuizzes.isEmpty {
                quizHistorySection
                    .phaseEntrance(index: 6)
            }
            accountSection
                .phaseEntrance(index: 7)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.xxl)
        .readableContentWidth()
    }
}

// MARK: - Helpers
private extension ProfileScreen {
    /// Reads the whole quiz history only when its count or owner changed since the last visit;
    /// the other stats are cheap and refresh every time.
    func refreshQuizData() {
        let userID = authService.currentUserID
        let predicate = #Predicate<QuizHistoryRecord> { $0.userID == userID }
        let count = (try? database.mainContext.fetchCount(FetchDescriptor(predicate: predicate))) ?? 0
        if quizTotals?.userID != userID || quizTotals?.quizCount != count {
            var descriptor = FetchDescriptor<QuizHistoryRecord>(predicate: predicate)
            descriptor.sortBy = [SortDescriptor(\QuizHistoryRecord.completedAt, order: .reverse)]
            let allQuizzes = (try? database.mainContext.fetch(descriptor)) ?? []
            recentQuizzes = Array(allQuizzes.prefix(3))
            quizTotals = QuizTotals(userID: userID, quizzes: allQuizzes)
        }
        statistics = quizTotals.map(buildStatistics)
    }

    func buildStatistics(from totals: QuizTotals) -> UserStatistics {
        let longestStreak = authService.currentProfile?.longestStreak ?? streakService.currentStreak

        return UserStatistics(
            totalQuizzes: totals.quizCount,
            totalCorrectAnswers: totals.correctAnswers,
            totalQuestions: totals.questions,
            perfectScores: totals.perfectScores,
            currentStreak: streakService.currentStreak,
            longestStreak: longestStreak,
            countriesExplored: explorationService.exploredCountryCodes.count,
            countriesVisited: travelService.visitedCodes.count,
            totalXP: xpService.totalXP,
            memberSince: authService.currentProfile?.createdAt ?? .now
        )
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if !authService.isGuest {
            ToolbarItem(placement: .topBarLeading) {
                editButton
            }
        }
    }

    @ViewBuilder
    var deleteAlertActions: some View {
        Button("Cancel", role: .cancel) {}
        Button("Delete", role: .destructive) {
            authService.deleteAccount()
        }
    }

    var deleteAlertMessage: some View {
        Text(
            "This will permanently delete your account, XP, achievements, "
            + "and quiz history. This action cannot be undone."
        )
    }
}

// MARK: - Quiz Totals
/// What the profile shows from one user's quiz history.
struct QuizTotals {
    let userID: String
    let quizCount: Int
    let correctAnswers: Int
    let questions: Int
    let perfectScores: Int

    init(userID: String, quizzes: [QuizHistoryRecord]) {
        self.userID = userID
        quizCount = quizzes.count
        correctAnswers = quizzes.reduce(0) { $0 + $1.correctCount }
        questions = quizzes.reduce(0) { $0 + $1.totalCount }
        perfectScores = quizzes.filter { $0.correctCount == $0.totalCount }.count
    }
}
#endif
