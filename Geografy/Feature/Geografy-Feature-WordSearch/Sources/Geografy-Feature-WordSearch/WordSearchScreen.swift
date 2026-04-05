import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct WordSearchScreen: View {
    // MARK: - Init
    public init() {}
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator

    @State private var selectedTheme: WordSearchTheme = .capitals
    @State private var showGuide = false

    // MARK: - Body
    public var body: some View {
        scrollContent
            .background(DesignSystem.Color.background)
            .navigationTitle("Word Search")
            .closeButtonPlacementLeading()
            .safeAreaInset(edge: .bottom) { startButton }
            .toolbar { toolbarContent }
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
            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(WordSearchTheme.allCases, id: \.self) { theme in
                    themeRow(theme)
                }
            }
        }
    }

    func themeRow(_ theme: WordSearchTheme) -> some View {
        let isSelected = selectedTheme == theme
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedTheme = theme
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: theme.icon)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.accent)
                    .frame(width: 28)
                Text(theme.rawValue)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(
                        isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary
                    )
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.onAccent)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            )
        }
        .buttonStyle(PressButtonStyle())
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

    var startButton: some View {
        GlassButton("Start Puzzle", systemImage: "play.fill", fullWidth: true) {
            coordinator.cover(.wordSearchGame(selectedTheme))
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
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

// MARK: - Toolbar
private extension WordSearchScreen {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        #if os(tvOS)
        ToolbarItem(placement: .automatic) {
            Button { showGuide = true } label: {
                Label("Guide", systemImage: "info.circle")
            }
        }
        #else
        ToolbarItem(placement: .topBarTrailing) {
            Button { showGuide = true } label: {
                Image(systemName: "info.circle")
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        #endif
    }
}
