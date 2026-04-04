import Geografy_Core_DesignSystem
import SwiftUI

struct HomeLearnCarousel: View {
    let srsCardsDue: Int
    let onItemTap: (LearnItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Learn & Grow")
                .padding(.horizontal, DesignSystem.Spacing.md)

            scrollContent
        }
    }
}

// MARK: - LearnItem
extension HomeLearnCarousel {
    enum LearnItem: CaseIterable {
        case learningPath
        case flashcards
        case oceanExplorer
        case languageExplorer
        case economy
        case culture
        case geographyFeatures
        case landmarks

        var name: String {
            switch self {
            case .learningPath: "Learning Path"
            case .flashcards: "Flashcards"
            case .oceanExplorer: "Ocean Explorer"
            case .languageExplorer: "Language Explorer"
            case .economy: "Economy"
            case .culture: "Culture"
            case .geographyFeatures: "Geography Features"
            case .landmarks: "Landmarks"
            }
        }

        var icon: String {
            switch self {
            case .learningPath: "graduationcap.fill"
            case .flashcards: "rectangle.on.rectangle.angled"
            case .oceanExplorer: "water.waves"
            case .languageExplorer: "character.book.closed.fill"
            case .economy: "chart.line.uptrend.xyaxis"
            case .culture: "music.note.house.fill"
            case .geographyFeatures: "mountain.2.fill"
            case .landmarks: "photo.on.rectangle.angled"
            }
        }

        var color: Color {
            switch self {
            case .learningPath: DesignSystem.Color.blue
            case .flashcards: DesignSystem.Color.purple
            case .oceanExplorer: DesignSystem.Color.blue
            case .languageExplorer: DesignSystem.Color.indigo
            case .economy: DesignSystem.Color.success
            case .culture: DesignSystem.Color.orange
            case .geographyFeatures: DesignSystem.Color.blue
            case .landmarks: DesignSystem.Color.orange
            }
        }
    }
}

// MARK: - Subviews
private extension HomeLearnCarousel {
    var scrollContent: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(LearnItem.allCases, id: \.self) { item in
                    Button { onItemTap(item) } label: {
                        itemCard(for: item)
                    }
                    .buttonStyle(PressButtonStyle())
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }

    func itemCard(for item: LearnItem) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.xs) {
                iconCircle(for: item)

                Text(item.name)
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 32)
            }
            .padding(DesignSystem.Spacing.sm)
            .frame(width: 130, height: 110)
        }
        .overlay(alignment: .topTrailing) {
            if item == .flashcards, srsCardsDue > 0 {
                dueBadge
            }
        }
    }

    func iconCircle(for item: LearnItem) -> some View {
        Circle()
            .fill(item.color.opacity(0.15))
            .frame(width: 36, height: 36)
            .overlay {
                Image(systemName: item.icon)
                    .font(DesignSystem.Font.iconSmall)
                    .foregroundStyle(item.color)
            }
    }

    var dueBadge: some View {
        Text("\(srsCardsDue)")
            .font(DesignSystem.Font.caption2)
            .fontWeight(.bold)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(DesignSystem.Color.error, in: Capsule())
            .offset(x: 4, y: -4)
    }
}
