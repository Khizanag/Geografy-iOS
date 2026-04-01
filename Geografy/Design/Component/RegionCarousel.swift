#if !os(tvOS)
import GeografyDesign
import SwiftUI

struct RegionCarousel: View {
    @Environment(CountryDataService.self) private var countryDataService
    @Environment(HapticsService.self) private var hapticsService

    @Binding var selectedRegion: QuizRegion

    @State private var visibleRegion: QuizRegion?

    var body: some View {
        extractedContent
            .onAppear { visibleRegion = selectedRegion }
    }
}

// MARK: - Subviews
private extension RegionCarousel {
    var extractedContent: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            carousel
            pageIndicator
        }
    }

    var carousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(QuizRegion.allCases) { region in
                    RegionCard(
                        region: region,
                        isSelected: region == currentRegion,
                        countryCount: region.filter(countryDataService.countries).count,
                        color: color(for: region),
                        description: description(for: region)
                    )
                    .containerRelativeFrame(
                        .horizontal,
                        count: 5,
                        span: 4,
                        spacing: DesignSystem.Spacing.sm
                    )
                    .id(region)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $visibleRegion)
        .scrollClipDisabled()
        .contentMargins(.horizontal, DesignSystem.Spacing.md)
        .onChange(of: visibleRegion) { _, newValue in
            guard let newValue, newValue != selectedRegion else { return }
            selectedRegion = newValue
            hapticsService.selection()
        }
    }

    var pageIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(QuizRegion.allCases) { region in
                Capsule()
                    .fill(
                        region == currentRegion
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.textTertiary.opacity(0.3)
                    )
                    .frame(
                        width: region == currentRegion ? 20 : 6,
                        height: 6
                    )
                    .animation(.easeInOut(duration: 0.25), value: currentRegion)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Helpers
private extension RegionCarousel {
    var currentRegion: QuizRegion {
        visibleRegion ?? selectedRegion
    }

    func color(for region: QuizRegion) -> Color {
        switch region {
        case .world: DesignSystem.Color.accent
        case .africa: DesignSystem.Color.warning
        case .asia: DesignSystem.Color.error
        case .europe: DesignSystem.Color.blue
        case .northAmerica: DesignSystem.Color.success
        case .southAmerica: DesignSystem.Color.orange
        case .oceania: DesignSystem.Color.indigo
        }
    }

    func description(for region: QuizRegion) -> String {
        switch region {
        case .world: "Name every country on Earth"
        case .africa: "The most country-dense continent"
        case .asia: "From Turkey to Japan"
        case .europe: "From Iceland to Cyprus"
        case .northAmerica: "US, Canada, Caribbean & Central"
        case .southAmerica: "From Colombia to Argentina"
        case .oceania: "Islands of the Pacific"
        }
    }
}

// MARK: - Region Card
private struct RegionCard: View {
    let region: QuizRegion
    let isSelected: Bool
    let countryCount: Int
    let color: Color
    let description: String

    var body: some View {
        cardContent
            .padding(.vertical, DesignSystem.Spacing.lg)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                    .fill(DesignSystem.Color.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                            .strokeBorder(
                                isSelected
                                    ? color.opacity(0.5)
                                    : DesignSystem.Color.cardBackgroundHighlighted,
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
            .hoverEffect(.highlight)
    }
}

// MARK: - Subviews
private extension RegionCard {
    var cardContent: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(isSelected ? 0.18 : 0.08))
                    .frame(width: 64, height: 64)

                Image(systemName: region.regionIcon)
                    .font(DesignSystem.Font.iconLarge.weight(.medium))
                    .foregroundStyle(color)
            }

            VStack(spacing: DesignSystem.Spacing.xxs) {
                Text(region.displayName)
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Text("\(countryCount) countries")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }

            Text(description)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 34)
        }
    }
}
#endif
