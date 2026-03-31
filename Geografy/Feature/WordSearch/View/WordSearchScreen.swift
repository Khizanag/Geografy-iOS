import SwiftUI
import GeografyDesign
import GeografyCore

struct WordSearchScreen: View {
    @Environment(Navigator.self) private var coordinator

    @State private var selectedTheme: WordSearchTheme = .capitals
    @State private var showGuide = false

    var body: some View {
        scrollContent
            .background(DesignSystem.Color.background)
            .navigationTitle("Word Search")
            .closeButtonPlacementLeading()
            .safeAreaInset(edge: .bottom) {
                GlassButton("Start Puzzle", systemImage: "play.fill", fullWidth: true) {
                    coordinator.cover(.wordSearchGame(selectedTheme))
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.md)
            }
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    Button { showGuide = true } label: {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(isPresented: $showGuide) { wordSearchGuide }
    }
}

// MARK: - Subviews
private extension WordSearchScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                heroSection
                themeSection
                howItWorksSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    var heroSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.12))
                    .frame(width: 96, height: 96)
                Image(systemName: "character.magnify")
                    .font(DesignSystem.Font.displayXS)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            Text("Find hidden country names\nin a grid of letters")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DesignSystem.Spacing.md)
    }

    var themeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Theme")
            Picker("Theme", selection: $selectedTheme) {
                ForEach(WordSearchTheme.allCases, id: \.self) { theme in
                    Label(theme.rawValue, systemImage: theme.icon).tag(theme)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "How It Works", icon: "lightbulb.fill")
            VStack(spacing: DesignSystem.Spacing.xs) {
                tipRow(icon: "hand.draw.fill", text: "Drag across letters to select a word")
                tipRow(icon: "checkmark.circle.fill", text: "Found words highlight in green")
                tipRow(icon: "clock.fill", text: "Timer tracks how fast you finish")
                tipRow(icon: "eye.fill", text: "Stuck? Reveal answers anytime")
            }
        }
    }

    func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption)
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
            in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
        )
    }

    var wordSearchGuide: some View {
        GuideSheet(
            pages: [
                GuidePage(
                    title: "Find Hidden Words",
                    subtitle: "Country names and capitals are hidden in a grid of letters. Drag to select them!",
                    steps: [
                        GuideStep(
                            icon: "hand.draw.fill", title: "Drag to Select",
                            description: "Drag across letters horizontally, vertically, or diagonally"
                        ),
                        GuideStep(
                            icon: "checkmark.circle.fill", title: "Words Highlight",
                            description: "Correctly found words turn green in the grid"
                        ),
                        GuideStep(
                            icon: "clock.fill", title: "Race the Clock",
                            description: "Your time is tracked — try to beat your best"
                        ),
                    ]
                ),
                GuidePage(
                    title: "Tips & Tricks",
                    subtitle: "Master the word search with these strategies.",
                    steps: [
                        GuideStep(
                            icon: "eye.fill", title: "Scan Systematically",
                            description: "Check each row and column one at a time"
                        ),
                        GuideStep(
                            icon: "arrow.left.arrow.right", title: "Words Go Both Ways",
                            description: "Words can be placed forward or backward"
                        ),
                        GuideStep(
                            icon: "arrow.up.left.and.arrow.down.right", title: "Try Diagonals",
                            description: "Don't forget diagonal words — they're sneaky"
                        ),
                    ]
                ),
            ]
        ) { _ in
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.accent.opacity(0.08))
                    .frame(width: 140, height: 140)
                Image(systemName: "character.magnify")
                    .font(DesignSystem.Font.displayMedium)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            .frame(height: 180)
        }
    }
}
