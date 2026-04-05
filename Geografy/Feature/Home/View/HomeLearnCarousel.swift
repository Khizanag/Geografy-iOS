import Geografy_Core_DesignSystem
import SwiftUI

struct HomeLearnCarousel: View {
    // MARK: - Properties
    let srsCardsDue: Int
    let onItemTap: (LearnItem) -> Void

    // MARK: - Body
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
            case .oceanExplorer: "Oceans"
            case .languageExplorer: "Languages"
            case .economy: "Economy"
            case .culture: "Culture"
            case .geographyFeatures: "Geography"
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

        var gradientColors: (Color, Color) {
            switch self {
            case .learningPath: (Color(hex: "1A73E8"), Color(hex: "0D47A1"))
            case .flashcards: (Color(hex: "8944AB"), Color(hex: "6A1B9A"))
            case .oceanExplorer: (Color(hex: "0288D1"), Color(hex: "01579B"))
            case .languageExplorer: (Color(hex: "5C6BC0"), Color(hex: "3949AB"))
            case .economy: (Color(hex: "43A047"), Color(hex: "2E7D32"))
            case .culture: (Color(hex: "FF8F00"), Color(hex: "E65100"))
            case .geographyFeatures: (Color(hex: "00838F"), Color(hex: "006064"))
            case .landmarks: (Color(hex: "D84315"), Color(hex: "BF360C"))
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
                        learnCard(item)
                    }
                    .buttonStyle(PressButtonStyle())
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.xs)
        }
        .scrollClipDisabled()
    }

    func learnCard(_ item: LearnItem) -> some View {
        let (primary, secondary) = item.gradientColors

        return ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [primary, secondary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(systemName: item.icon)
                .font(DesignSystem.IconSize.xxLarge)
                .foregroundStyle(.white.opacity(0.1))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .offset(x: 8, y: -8)
                .clipped()

            Text(item.name)
                .font(DesignSystem.Font.caption)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .lineLimit(2)
                .padding(DesignSystem.Spacing.sm)
        }
        .frame(width: 140, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large))
        .shadow(color: primary.opacity(0.3), radius: 6, y: 4)
        .overlay(alignment: .topTrailing) {
            if item == .flashcards, srsCardsDue > 0 {
                dueBadge
            }
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
