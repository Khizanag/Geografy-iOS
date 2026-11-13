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
    @Environment(FavoritesService.self) var favoritesService
    @Environment(DatabaseManager.self) var database
    @Environment(HapticsService.self) var hapticsService
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @State var recentQuizzes: [QuizHistoryRecord] = []
    @State var statistics: UserStatistics?
    @State var showDeleteAlert = false
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
            .alert("Delete Account", isPresented: $showDeleteAlert) {
                deleteAlertActions
            } message: {
                deleteAlertMessage
            }
            .onAppear { fetchQuizData() }
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
    func fetchQuizData() {
        let userID = authService.currentUserID
        var descriptor = FetchDescriptor<QuizHistoryRecord>(
            predicate: #Predicate { $0.userID == userID }
        )
        descriptor.sortBy = [SortDescriptor(\QuizHistoryRecord.completedAt, order: .reverse)]
        let allQuizzes = (try? database.mainContext.fetch(descriptor)) ?? []
        recentQuizzes = Array(allQuizzes.prefix(3))
        statistics = buildStatistics(from: allQuizzes)
    }

    func buildStatistics(from quizzes: [QuizHistoryRecord]) -> UserStatistics {
        let totalCorrect = quizzes.reduce(0) { $0 + $1.correctCount }
        let totalQuestions = quizzes.reduce(0) { $0 + $1.totalCount }
        let perfectCount = quizzes.filter { $0.correctCount == $0.totalCount }.count
        let longestStreak = authService.currentProfile?.longestStreak ?? streakService.currentStreak

        return UserStatistics(
            totalQuizzes: quizzes.count,
            totalCorrectAnswers: totalCorrect,
            totalQuestions: totalQuestions,
            perfectScores: perfectCount,
            currentStreak: streakService.currentStreak,
            longestStreak: longestStreak,
            countriesExplored: favoritesService.favoriteCodes.count,
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
#endif
