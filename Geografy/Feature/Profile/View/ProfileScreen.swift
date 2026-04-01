import GeografyCore
import GeografyDesign
import SwiftData
import SwiftUI

struct ProfileScreen: View {
    @Environment(Navigator.self) var coordinator
    @Environment(SubscriptionService.self) var subscriptionService
    @Environment(AuthService.self) var authService
    @Environment(XPService.self) var xpService
    @Environment(StreakService.self) var streakService
    @Environment(AchievementService.self) var achievementService
    @Environment(TravelService.self) var travelService
    @Environment(FavoritesService.self) var favoritesService
    @Environment(DatabaseManager.self) var database
    @Environment(HapticsService.self) var hapticsService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State var recentQuizzes: [QuizHistoryRecord] = []
    @State var statistics: UserStatistics?
    @State var showDeleteAlert = false
    @State private var blobAnimating = false
    @State private var appeared = false

    var body: some View {
        scrollContent
            .background { ambientBlobs }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent }
            .alert("Delete Account", isPresented: $showDeleteAlert) {
                deleteAlertActions
            } message: {
                deleteAlertMessage
            }
            .onAppear { handleAppear() }
    }
}

// MARK: - Scroll Content
private extension ProfileScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                if authService.isGuest {
                    guestBanner
                        .profileSection(appeared: appeared, delay: 0.03)
                }
                headerSection
                    .profileSection(appeared: appeared, delay: 0.06)
                levelProgressSection
                    .profileSection(appeared: appeared, delay: 0.10)
                statsGridSection
                    .profileSection(appeared: appeared, delay: 0.14)
                weeklyActivitySection
                    .profileSection(appeared: appeared, delay: 0.16)
                achievementsPreviewSection
                    .profileSection(appeared: appeared, delay: 0.20)
                badgeShowcaseSection
                    .profileSection(appeared: appeared, delay: 0.22)
                if !recentQuizzes.isEmpty {
                    quizHistorySection
                        .profileSection(appeared: appeared, delay: 0.26)
                }
                if !subscriptionService.isPremium {
                    premiumBannerSection
                        .profileSection(appeared: appeared, delay: 0.30)
                }
                accountSection
                    .profileSection(appeared: appeared, delay: 0.34)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }
}

// MARK: - Background
private extension ProfileScreen {
    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.accent.opacity(0.22), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 220
                    )
                )
                .frame(width: 440, height: 320)
                .blur(radius: 32)
                .offset(x: -80, y: -80)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.indigo.opacity(0.18), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 300)
                .blur(radius: 40)
                .offset(x: 140, y: 80)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [DesignSystem.Color.purple.opacity(0.12), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 260)
                .blur(radius: 36)
                .offset(x: -100, y: 600)
                .scaleEffect(blobAnimating ? 1.06 : 0.94)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: blobAnimating)
    }
}

// MARK: - Helpers
private extension ProfileScreen {
    func fetchQuizData() {
        let userID = authService.currentUserID
        var descriptor = FetchDescriptor<QuizHistoryRecord>(
            predicate: #Predicate { $0.userID == userID }
        )
        descriptor.sortBy = [SortDescriptor(\.completedAt, order: .reverse)]
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

    func handleAppear() {
        fetchQuizData()
        guard !reduceMotion else {
            blobAnimating = true
            appeared = true
            return
        }
        blobAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            appeared = true
        }
    }
}

// MARK: - Profile Section Modifier
private extension View {
    func profileSection(appeared: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 14)
            .animation(.easeOut(duration: 0.45).delay(delay), value: appeared)
    }
}
