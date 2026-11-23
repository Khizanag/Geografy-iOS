import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import SwiftUI

public struct WordSearchScreen: View {
    // MARK: - Properties
    @Environment(\.locale) private var locale
    @Environment(Navigator.self) private var coordinator
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @AppStorage("wordSearch_selectedTheme") private var selectedTheme: WordSearchTheme = .capitals

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
            .bottomActionBar { startButton }
            .gameGuide(.wordSearch)
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
            title: String(localized: "Word Search", bundle: .module, in: locale),
            subtitle: String(
                localized: "Drag across the letters to find every hidden word.",
                bundle: .module,
                in: locale
            ),
            systemImage: "character.magnify",
            color: color,
            facts: facts
        )
    }

    var themeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: String(localized: "Theme", bundle: .module, in: locale))
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
            coordinator.cover(PlayLocalRoute.wordSearchGame(selectedTheme))
        }
        .accessibilityHint(Text("Starts a \(selectedTheme.rawValue) puzzle"))
    }
}

// MARK: - Helpers
private extension WordSearchScreen {
    var facts: [GameIntroHeader.Fact] {
        let gridSize = service.gridSize
        let directionCount = WordSearchDirection.allCases.count
        return [
            GameIntroHeader.Fact(
                String(localized: "\(gridSize) × \(gridSize) grid", bundle: .module, in: locale),
                systemImage: "square.grid.3x3"
            ),
            GameIntroHeader.Fact(
                String(localized: "\(directionCount) directions", bundle: .module, in: locale),
                systemImage: "arrow.up.and.down.and.arrow.left.and.right"
            ),
            GameIntroHeader.Fact(
                String(localized: "Timed", bundle: .module, in: locale),
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
