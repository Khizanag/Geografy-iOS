import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct WordSearchScreen: View {
    // MARK: - Properties
    @Environment(Navigator.self) private var coordinator
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @AppStorage("wordSearch_selectedTheme") private var selectedTheme: WordSearchTheme = .capitals

    @State private var showGuide = false

    private let service = WordSearchService()
    private let color = DesignSystem.Color.indigo

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            .navigationTitle("Word Search")
            .navigationBarTitleDisplayMode(.inline)
            .closeButtonPlacementLeading()
            .safeAreaBar(edge: .bottom) { startButton }
            .toolbar { toolbarContent }
            .sheet(isPresented: $showGuide) { wordSearchGuide }
    }
}

// MARK: - Subviews
private extension WordSearchScreen {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                introHeader
                themeSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
    }

    var introHeader: some View {
        GameIntroHeader(
            title: String(localized: "Word Search", bundle: .module),
            subtitle: String(localized: "Drag across the letters to find every hidden word.", bundle: .module),
            systemImage: "character.magnify",
            color: color,
            facts: facts
        )
    }

    var themeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: String(localized: "Theme", bundle: .module))
            themeGrid
        }
    }

    // Two columns side by side; one column at accessibility sizes so names and samples never truncate.
    @ViewBuilder
    var themeGrid: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(WordSearchTheme.allCases, id: \.self) { theme in
                    themeTile(theme)
                }
            }
        } else {
            Grid(horizontalSpacing: DesignSystem.Spacing.sm, verticalSpacing: DesignSystem.Spacing.sm) {
                ForEach(themeRows, id: \.self) { row in
                    GridRow {
                        ForEach(row, id: \.self) { theme in
                            themeTile(theme)
                        }
                    }
                }
            }
        }
    }

    func themeTile(_ theme: WordSearchTheme) -> some View {
        WordSearchThemeTile(theme: theme, isSelected: selectedTheme == theme) {
            selectedTheme = theme
        }
    }

    var startButton: some View {
        GlassButton("Start Puzzle", systemImage: "play.fill", fullWidth: true) {
            coordinator.cover(.wordSearchGame(selectedTheme))
        }
        .accessibilityHint(Text("Starts a \(selectedTheme.rawValue) puzzle"))
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Guide
private extension WordSearchScreen {
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
            IconBadge("character.magnify", color: color, size: .hero)
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
                Label("Guide", systemImage: "questionmark.circle")
            }
        }
        #else
        ToolbarItem(placement: .topBarTrailing) {
            Button { showGuide = true } label: {
                Label("Guide", systemImage: "questionmark.circle")
            }
        }
        #endif
    }
}

// MARK: - Helpers
private extension WordSearchScreen {
    var facts: [GameIntroHeader.Fact] {
        let gridSize = service.gridSize
        let directionCount = WordSearchDirection.allCases.count
        return [
            GameIntroHeader.Fact(
                String(localized: "\(gridSize) × \(gridSize) grid", bundle: .module),
                systemImage: "square.grid.3x3"
            ),
            GameIntroHeader.Fact(
                String(localized: "\(directionCount) directions", bundle: .module),
                systemImage: "arrow.up.and.down.and.arrow.left.and.right"
            ),
            GameIntroHeader.Fact(
                String(localized: "Timed", bundle: .module),
                systemImage: "timer"
            ),
        ]
    }

    var themeRows: [[WordSearchTheme]] {
        let themes = WordSearchTheme.allCases
        let columns = 2
        return stride(from: 0, to: themes.count, by: columns).map { start in
            Array(themes[start..<min(start + columns, themes.count)])
        }
    }
}
