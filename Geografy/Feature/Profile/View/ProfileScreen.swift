import SwiftData
import SwiftUI

struct ProfileScreen: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(AuthService.self) private var authService
    @Environment(XPService.self) private var xpService
    @Environment(StreakService.self) private var streakService
    @Environment(AchievementService.self) private var achievementService
    @Environment(TravelService.self) private var travelService
    @Environment(FavoritesService.self) private var favoritesService
    @Environment(DatabaseManager.self) private var database

    @State private var recentQuizzes: [QuizHistoryRecord] = []
    @State private var totalQuizCount: Int = 0
    @State private var activeSheet: ProfileSheet?
    @State private var showDeleteAlert = false
    @State private var blobAnimating = false
    @State private var appeared = false

    var body: some View {
        scrollContent
            .background { ambientBlobs }
            .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .sheet(item: $activeSheet) { sheet in profileSheetContent(for: sheet) }
        .alert("Delete Account", isPresented: $showDeleteAlert, actions: { deleteAlertActions }, message: { deleteAlertMessage })
        .onAppear { handleAppear() }
    }
}

// MARK: - Scroll Content

private extension ProfileScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                headerSection
                    .profileSection(appeared: appeared, delay: 0.05)
                statsGridSection
                    .profileSection(appeared: appeared, delay: 0.10)
                achievementsPreviewSection
                    .profileSection(appeared: appeared, delay: 0.15)
                if !recentQuizzes.isEmpty {
                    quizHistorySection
                        .profileSection(appeared: appeared, delay: 0.20)
                }
                if !subscriptionService.isPremium {
                    premiumBannerSection
                        .profileSection(appeared: appeared, delay: 0.22)
                }
                accountSection
                    .profileSection(appeared: appeared, delay: 0.25)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
    }
}

// MARK: - Header

private extension ProfileScreen {
    var headerSection: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    avatarView
                    userInfoStack
                    Spacer()
                }
                Divider()
                    .overlay(Color.white.opacity(0.06))
                HStack(spacing: DesignSystem.Spacing.md) {
                    LevelBadgeView(level: xpService.currentLevel, size: .small, animated: true)
                    XPProgressBar(
                        currentLevelNumber: xpService.currentLevel.level,
                        nextLevelNumber: xpService.currentLevel.level < 10 ? xpService.currentLevel.level + 1 : nil,
                        xpInCurrentLevel: xpService.xpInCurrentLevel,
                        xpRequiredForNextLevel: xpService.xpRequiredForNextLevel,
                        progressFraction: xpService.progressFraction
                    )
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var avatarView: some View {
        ProfileAvatarView(name: displayName, size: 64)
            .shadow(color: DesignSystem.Color.accent.opacity(0.35), radius: 12, x: 0, y: 4)
    }

    var userInfoStack: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            Text(displayName)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
            if let email = authService.currentProfile?.email {
                Text(email)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(1)
            }
            if authService.isGuest {
                Text("Guest Mode")
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.warning)
                    .padding(.horizontal, DesignSystem.Spacing.xs)
                    .padding(.vertical, 2)
                    .background(DesignSystem.Color.warning.opacity(0.15), in: Capsule())
            }
        }
    }

    var editButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            activeSheet = .editProfile
        } label: {
            Image(systemName: "pencil")
        }
    }

    var displayName: String {
        authService.currentProfile?.displayName ?? "Explorer"
    }

}

// MARK: - Stats Grid

private extension ProfileScreen {
    var statsGridSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title:"Statistics")
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
                    GridItem(.flexible()),
                ],
                spacing: DesignSystem.Spacing.sm
            ) {
                statCard(icon: "bolt.fill", color: DesignSystem.Color.accent,
                         value: "\(xpService.totalXP)", label: "Total XP")
                statCard(icon: "star.fill", color: .yellow,
                         value: "Lv. \(xpService.currentLevel.level)", label: "Level")
                statCard(icon: "globe.americas.fill", color: DesignSystem.Color.blue,
                         value: "\(favoritesService.favoriteCodes.count)", label: "Explored")
                statCard(icon: "airplane.departure", color: Color(hex: "00C9A7"),
                         value: "\(travelService.visitedCodes.count)", label: "Visited")
                statCard(icon: "gamecontroller.fill", color: DesignSystem.Color.purple,
                         value: "\(totalQuizCount)", label: "Quizzes")
                statCard(icon: "flame.fill", color: DesignSystem.Color.error,
                         value: "\(streakService.currentStreak)", label: "Day Streak")
            }
        }
    }

    func statCard(icon: String, color: Color, value: String, label: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text(label)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(DesignSystem.Spacing.xs)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Achievements Preview

private extension ProfileScreen {
    var achievementsPreviewSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                SectionHeaderView(title:"Achievements")
                Spacer()
                Text("\(achievementService.unlockedAchievements.count) / \(AchievementCatalog.all.count)")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            if recentUnlockedAchievements.isEmpty {
                emptyAchievementsView
            } else {
                achievementsScrollRow
            }
        }
    }

    var achievementsScrollRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(recentUnlockedAchievements) { definition in
                    miniAchievementCard(definition)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .padding(.horizontal, -DesignSystem.Spacing.md)
    }

    var emptyAchievementsView: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "trophy")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
            Text("Start exploring to earn achievements!")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func miniAchievementCard(_ definition: AchievementDefinition) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            ZStack {
                Circle()
                    .fill(achievementColor(for: definition.category).opacity(0.2))
                    .frame(width: 48, height: 48)
                Image(systemName: definition.iconName)
                    .font(.system(size: 20))
                    .foregroundStyle(achievementColor(for: definition.category))
            }
            Text(definition.title)
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 72)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    var recentUnlockedAchievements: [AchievementDefinition] {
        achievementService.unlockedAchievements
            .sorted { $0.unlockedAt > $1.unlockedAt }
            .prefix(4)
            .compactMap { unlocked in AchievementCatalog.all.first { $0.id == unlocked.id } }
    }

    func achievementColor(for category: AchievementCategory) -> Color {
        switch category {
        case .explorer:      DesignSystem.Color.blue
        case .quizMaster:    DesignSystem.Color.purple
        case .travelTracker: DesignSystem.Color.orange
        case .streak:        DesignSystem.Color.error
        case .knowledge:     DesignSystem.Color.ocean
        }
    }
}

// MARK: - Quiz History

private extension ProfileScreen {
    var quizHistorySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title:"Recent Quizzes")
            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(recentQuizzes.prefix(3), id: \.id) { record in
                    quizHistoryRow(record)
                }
            }
        }
    }

    func quizHistoryRow(_ record: QuizHistoryRecord) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.purple.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: QuizType(rawValue: record.quizType)?.icon ?? "gamecontroller.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(DesignSystem.Color.purple)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(QuizType(rawValue: record.quizType)?.displayName ?? record.quizType)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(record.completedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(record.correctCount)/\(record.totalCount)")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(scoreColor(accuracy: record.accuracy))
                Text("+\(record.xpEarned) XP")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

    func scoreColor(accuracy: Double) -> Color {
        switch accuracy {
        case 0.8...1.0: DesignSystem.Color.success
        case 0.5..<0.8: DesignSystem.Color.warning
        default:        DesignSystem.Color.error
        }
    }
}

// MARK: - Premium Banner

private extension ProfileScreen {
    var premiumBannerSection: some View {
        Button { activeSheet = .paywall } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Color.accent.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(DesignSystem.Color.accent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Get Geografy Premium")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("Unlock all 6 quiz types, advanced stats & more")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                LinearGradient(
                    colors: [DesignSystem.Color.accent.opacity(0.12), DesignSystem.Color.accent.opacity(0.05)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            )
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .strokeBorder(DesignSystem.Color.accent.opacity(0.25), lineWidth: 1)
            }
        }
        .buttonStyle(GeoPressButtonStyle())
    }
}

// MARK: - Account Section

private extension ProfileScreen {
    var accountSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title:"Account")
            VStack(spacing: DesignSystem.Spacing.xs) {
                if authService.isGuest {
                    signInRow
                } else {
                    signOutRow
                }
                if !authService.isGuest {
                    deleteAccountRow
                }
            }
        }
    }

    var signInRow: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            activeSheet = .signIn
        } label: {
            accountRowLabel(
                icon: "person.badge.plus.fill",
                title: "Sign In",
                color: DesignSystem.Color.accent
            )
        }
        .buttonStyle(GeoPressButtonStyle())
    }

    var signOutRow: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            authService.signOut()
        } label: {
            accountRowLabel(
                icon: "arrow.right.square.fill",
                title: "Sign Out",
                color: DesignSystem.Color.textSecondary
            )
        }
        .buttonStyle(GeoPressButtonStyle())
    }

    var deleteAccountRow: some View {
        Button {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            showDeleteAlert = true
        } label: {
            accountRowLabel(
                icon: "trash.fill",
                title: "Delete Account",
                color: DesignSystem.Color.error
            )
        }
        .buttonStyle(GeoPressButtonStyle())
    }

    func accountRowLabel(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
            }
            Text(title)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
            Spacer()
            Image(systemName: "chevron.right")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }

}

// MARK: - Background

private extension ProfileScreen {
    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.accent.opacity(0.25), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 220
                ))
                .frame(width: 440, height: 320)
                .blur(radius: 32)
                .offset(x: -80, y: -80)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)
            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.indigo.opacity(0.18), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 180
                ))
                .frame(width: 360, height: 300)
                .blur(radius: 40)
                .offset(x: 140, y: 80)
                .scaleEffect(blobAnimating ? 0.88 : 1.10)
            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.blue.opacity(0.12), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 160
                ))
                .frame(width: 320, height: 260)
                .blur(radius: 36)
                .offset(x: -100, y: 400)
                .scaleEffect(blobAnimating ? 1.06 : 0.94)
            Ellipse()
                .fill(RadialGradient(
                    colors: [DesignSystem.Color.purple.opacity(0.10), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 160
                ))
                .frame(width: 320, height: 280)
                .blur(radius: 44)
                .offset(x: 160, y: 700)
                .scaleEffect(blobAnimating ? 0.92 : 1.08)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Sheet Type

private extension ProfileScreen {
    enum ProfileSheet: Identifiable {
        case editProfile
        case signIn
        case paywall

        var id: Self { self }
    }

    @ViewBuilder
    func profileSheetContent(for sheet: ProfileSheet) -> some View {
        switch sheet {
        case .editProfile:
            EditProfileSheet()
        case .signIn:
            SignInOptionsSheet()
        case .paywall:
            PaywallScreen()
        }
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
        let all = (try? database.mainContext.fetch(descriptor)) ?? []
        totalQuizCount = all.count
        recentQuizzes = Array(all.prefix(3))
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if !authService.isGuest {
            ToolbarItem(placement: .topBarLeading) {
                editButton
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            GeoCircleCloseButton()
        }
    }

    @ViewBuilder
    var deleteAlertActions: some View {
        Button("Cancel", role: .cancel) {}
        Button("Delete", role: .destructive) {
            authService.deleteAccount()
        }
    }

    // swiftlint:disable:next line_length
    var deleteAlertMessage: some View {
        Text("This will permanently delete your account, XP, achievements, and quiz history. This action cannot be undone.")
    }

    func handleAppear() {
        fetchQuizData()
        withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
            blobAnimating = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.4)) {
                appeared = true
            }
        }
    }
}

// MARK: - Profile Section Modifier

private extension View {
    func profileSection(appeared: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(delay), value: appeared)
    }
}
