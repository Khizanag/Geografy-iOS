import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct BorderChallengeScreen: View {
    // MARK: - Init
    public init() {}

    // MARK: - Properties
    @Environment(CountryDataService.self) private var countryDataService
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif

    @AppStorage("bc_difficulty") private var selectedDifficulty: BorderChallengeService.Difficulty = .medium
    @AppStorage("bc_region") private var selectedRegion: QuizRegion = .world

    @State private var showGuide = false
    @State private var showSession = false
    @State private var appeared = false

    // MARK: - Body
    public var body: some View {
        scrollContent
            .background { AmbientBlobsView(.quiz) }
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Border Challenge")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .safeAreaInset(edge: .bottom) { startButton }
            .toolbar { toolbarContent }
            .onAppear { appeared = true }
            .fullScreenCover(isPresented: $showSession) {
                BorderChallengeSessionScreen(
                    difficulty: selectedDifficulty,
                    region: selectedRegion
                )
            }
            .sheet(isPresented: $showGuide) {
                BorderChallengeGuideSheet()
            }
    }
}

// MARK: - Subviews
private extension BorderChallengeScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                heroSection
                difficultySection
                regionSection
                bestScoresSection
                howItWorksSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }
}

// MARK: - Hero
private extension BorderChallengeScreen {
    var heroSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [DesignSystem.Color.accent.opacity(0.2), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "map.fill")
                    .font(DesignSystem.IconSize.hero)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .symbolEffect(.pulse, options: .repeating)
            }

            Text("Border Challenge")
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("Name all neighboring countries before time runs out")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignSystem.Spacing.md)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5), value: appeared)
    }
}

// MARK: - Difficulty
private extension BorderChallengeScreen {
    var difficultySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Difficulty")

            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(BorderChallengeService.Difficulty.allCases, id: \.self) { difficulty in
                    difficultyCard(difficulty)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    func difficultyCard(_ difficulty: BorderChallengeService.Difficulty) -> some View {
        let isSelected = selectedDifficulty == difficulty
        return Button {
            #if !os(tvOS)
            hapticsService.impact(.light)
            #endif
            selectedDifficulty = difficulty
        } label: {
            difficultyCardLabel(difficulty, isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(difficulty.rawValue) difficulty")
        .accessibilityValue(isSelected ? "Selected" : "")
        .accessibilityHint(difficulty.subtitle)
    }

    func difficultyCardLabel(_ difficulty: BorderChallengeService.Difficulty, isSelected: Bool) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: difficulty.icon)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.accent)

            Text(difficulty.rawValue)
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)

            Text(difficulty.subtitle)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(
                    isSelected ? DesignSystem.Color.onAccent.opacity(0.8) : DesignSystem.Color.textSecondary
                )

            Text("\(difficulty.timeLimit)s")
                .font(DesignSystem.Font.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(
                    isSelected ? DesignSystem.Color.onAccent.opacity(0.9) : DesignSystem.Color.textTertiary
                )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(
            isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(
                    isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackgroundHighlighted,
                    lineWidth: 1.5
                )
        )
    }
}

// MARK: - Region
private extension BorderChallengeScreen {
    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Region")

            RegionSelectionBar(
                items: QuizRegion.allCases,
                selectedID: selectedRegion.id,
                onSelect: { region in
                    selectedRegion = region
                }
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
    }
}

// MARK: - Best Scores
private extension BorderChallengeScreen {
    var bestScoresSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Your Stats")

            HStack(spacing: DesignSystem.Spacing.sm) {
                statCard(
                    icon: "trophy.fill",
                    value: "\(bestScore)",
                    label: "Best Score",
                    color: DesignSystem.Color.warning
                )
                statCard(
                    icon: "flame.fill",
                    value: "\(gamesPlayed)",
                    label: "Games Played",
                    color: DesignSystem.Color.error
                )
                statCard(
                    icon: "percent",
                    value: "\(averageAccuracy)%",
                    label: "Avg Accuracy",
                    color: DesignSystem.Color.accent
                )
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
    }

    func statCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(color)
            Text(value)
                .font(DesignSystem.Font.title3)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .contentTransition(.numericText())
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }
}

// MARK: - How It Works
private extension BorderChallengeScreen {
    var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "How It Works")

            VStack(spacing: DesignSystem.Spacing.xs) {
                ruleRow(step: "1", icon: "globe.americas.fill", text: "A random country is shown with its flag")
                ruleRow(step: "2", icon: "keyboard", text: "Type the names of its neighboring countries")
                ruleRow(step: "3", icon: "timer", text: "Find them all before the timer runs out")
                ruleRow(step: "4", icon: "star.fill", text: "Earn XP based on speed and accuracy")
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.25), value: appeared)
    }

    func ruleRow(step: String, icon: String, text: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Text(step)
                .font(DesignSystem.Font.caption)
                .fontWeight(.black)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .frame(width: 24, height: 24)
                .background(DesignSystem.Color.accent, in: Circle())

            Image(systemName: icon)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.accent)
                .frame(width: 24)

            Text(text)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Spacer(minLength: 0)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackground,
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small)
        )
    }
}

// MARK: - Toolbar
private extension BorderChallengeScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        #if os(tvOS)
        ToolbarItem(placement: .automatic) {
            Button { showGuide = true } label: {
                Label("Guide", systemImage: "info.circle")
            }
        }
        #else
        ToolbarItem(placement: .secondaryAction) {
            Button { showGuide = true } label: {
                Label("Guide", systemImage: "info.circle")
            }
        }
        #endif
    }
}

// MARK: - Start Button
private extension BorderChallengeScreen {
    var startButton: some View {
        GlassButton("Start Challenge", systemImage: "play.fill", fullWidth: true) {
            #if !os(tvOS)
            hapticsService.impact(.medium)
            #endif
            showSession = true
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Stats Helpers
private extension BorderChallengeScreen {
    var bestScore: Int {
        UserDefaults.standard.integer(forKey: "bc_bestScore_\(selectedDifficulty.rawValue)")
    }

    var gamesPlayed: Int {
        UserDefaults.standard.integer(forKey: "bc_gamesPlayed")
    }

    var averageAccuracy: Int {
        let total = UserDefaults.standard.integer(forKey: "bc_totalAccuracy")
        let count = gamesPlayed
        guard count > 0 else { return 0 }
        return total / count
    }
}
