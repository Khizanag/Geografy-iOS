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
    @State private var showEditProfile = false
    @State private var showSignIn = false
    @State private var showPaywall = false
    @State private var showDeleteAlert = false
    @State private var blobAnimating = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            DesignSystem.Color.background.ignoresSafeArea()
            ambientBlobs
            scrollContent
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                editButton
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet()
        }
        .sheet(isPresented: $showSignIn) {
            SignInOptionsSheet()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallScreen()
        }
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                authService.deleteAccount()
            }
        } message: {
            // swiftlint:disable:next line_length
            Text("This will permanently delete your account, XP, achievements, and quiz history. This action cannot be undone.")
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                blobAnimating = true
            }
            withAnimation(.easeOut(duration: 0.5)) {
                appeared = true
            }
            fetchQuizData()
        }
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
        GeoCard {
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
        ZStack {
            Circle()
                .fill(avatarGradient)
                .frame(width: 72, height: 72)
            Text(avatarInitials)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.white)
        }
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
            showEditProfile = true
        } label: {
            Image(systemName: "pencil")
        }
    }

    var displayName: String {
        authService.currentProfile?.displayName ?? "Explorer"
    }

    var avatarInitials: String {
        let name = displayName
        let words = name.split(separator: " ")
        if words.count >= 2 {
            return "\(words[0].prefix(1))\(words[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    var avatarGradient: LinearGradient {
        LinearGradient(
            colors: [DesignSystem.Color.accent, DesignSystem.Color.accentDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Stats Grid

private extension ProfileScreen {
    var statsGridSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionLabel("Statistics")
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
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                Text(label)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer()
        }
        .padding(DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}

// MARK: - Achievements Preview

private extension ProfileScreen {
    var achievementsPreviewSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                sectionLabel("Achievements")
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
            sectionLabel("Recent Quizzes")
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
        Button { showPaywall = true } label: {
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
            sectionLabel("Account")
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
            appVersionInfo
        }
    }

    var signInRow: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            showSignIn = true
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

    var appVersionInfo: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return Text("Geografy v\(version) (\(build))")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, DesignSystem.Spacing.xs)
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

// MARK: - Helpers

private extension ProfileScreen {
    func sectionLabel(_ title: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            RoundedRectangle(cornerRadius: 2)
                .fill(DesignSystem.Color.accent)
                .frame(width: 3, height: 18)
            Text(title)
                .font(DesignSystem.Font.title2)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
    }

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
}

// MARK: - Profile Section Modifier

private extension View {
    func profileSection(appeared: Bool, delay: Double) -> some View {
        self
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 16)
            .animation(.easeOut(duration: 0.5).delay(delay), value: appeared)
    }
}
