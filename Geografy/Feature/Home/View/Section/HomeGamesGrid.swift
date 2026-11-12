import Geografy_Core_DesignSystem
import SwiftUI

struct HomeGamesGrid: View {
    // MARK: - Properties
    let onGameTap: (GameItem) -> Void
    let onSeeAll: () -> Void

    private let columns = [
        GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.sm),
    ]

    // MARK: - Body
    var body: some View {
        content
    }
}

// MARK: - GameItem
extension HomeGamesGrid {
    enum GameItem: String, CaseIterable {
        case quiz
        case trueOrFalse
        case mapPuzzle
        case neighbors
        case mysteryCountry
        case wordSearch

        var name: String {
            switch self {
            case .quiz: "Quiz"
            case .trueOrFalse: "True or False"
            case .mapPuzzle: "Map Puzzle"
            case .neighbors: "Neighbors"
            case .mysteryCountry: "Mystery Country"
            case .wordSearch: "Word Search"
            }
        }

        var icon: String {
            switch self {
            case .quiz: "gamecontroller.fill"
            case .trueOrFalse: "questionmark.bubble.fill"
            case .mapPuzzle: "puzzlepiece.fill"
            case .neighbors: "square.dashed"
            case .mysteryCountry: "magnifyingglass"
            case .wordSearch: "character.magnify"
            }
        }

        var color: Color {
            switch self {
            case .quiz: DesignSystem.Color.accent
            case .trueOrFalse: DesignSystem.Color.blue
            case .mapPuzzle: DesignSystem.Color.purple
            case .neighbors: DesignSystem.Color.error
            case .mysteryCountry: DesignSystem.Color.orange
            case .wordSearch: DesignSystem.Color.indigo
            }
        }

        var isNew: Bool {
            switch self {
            case .mapPuzzle, .wordSearch: true
            default: false
            }
        }
    }
}

// MARK: - Subviews
private extension HomeGamesGrid {
    var content: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            header

            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.sm) {
                ForEach(GameItem.allCases, id: \.self) { game in
                    gameChip(for: game)
                }
            }
        }
    }

    var header: some View {
        HStack {
            SectionHeaderView(title: "Play", icon: "play.fill")

            Spacer()

            Button {
                onSeeAll()
            } label: {
                Text("See All")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
            .buttonStyle(.plain)
        }
    }

    func gameChip(for game: GameItem) -> some View {
        Button {
            onGameTap(game)
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    iconCircle(for: game)

                    Text(game.name)
                        .font(DesignSystem.Font.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .lineLimit(1)

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .frame(height: 52)
            }
            .overlay(alignment: .topTrailing) {
                if game.isNew {
                    newTag
                }
            }
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel(game.name)
    }

    var newTag: some View {
        Text("NEW")
            .font(DesignSystem.Font.caption2)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, DesignSystem.Spacing.xxs)
            .padding(.vertical, 2)
            .background(DesignSystem.Color.accent, in: Capsule())
            .offset(x: -DesignSystem.Spacing.xs, y: DesignSystem.Spacing.xs)
    }

    func iconCircle(for game: GameItem) -> some View {
        Circle()
            .fill(game.color.opacity(0.15))
            .frame(width: DesignSystem.Spacing.xl, height: DesignSystem.Spacing.xl)
            .overlay {
                Image(systemName: game.icon)
                    .font(DesignSystem.Font.iconSmall)
                    .foregroundStyle(game.color)
            }
            .accessibilityHidden(true)
    }
}
