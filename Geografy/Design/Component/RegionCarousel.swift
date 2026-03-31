import SwiftUI

struct RegionCarousel: View {
    @Environment(HapticsService.self) private var hapticsService

    @Binding var selectedRegion: QuizRegion

    @State private var countryDataService = CountryDataService()

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            carousel
            pageIndicator
        }
        .task { countryDataService.loadCountries() }
    }
}

// MARK: - Subviews
private extension RegionCarousel {
    var carousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(QuizRegion.allCases) { region in
                    regionCard(region)
                        .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: Binding<QuizRegion?>(
            get: { selectedRegion },
            set: { if let value = $0 { selectedRegion = value } }
        ))
        .scrollClipDisabled()
        .contentMargins(.horizontal, DesignSystem.Spacing.md)
    }

    var pageIndicator: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(QuizRegion.allCases) { region in
                Capsule()
                    .fill(
                        region == selectedRegion
                            ? DesignSystem.Color.accent
                            : DesignSystem.Color.textTertiary.opacity(0.3)
                    )
                    .frame(
                        width: region == selectedRegion ? 20 : 6,
                        height: 6
                    )
                    .animation(.easeInOut(duration: 0.25), value: selectedRegion)
            }
        }
        .frame(maxWidth: .infinity)
    }

    func regionCard(_ region: QuizRegion) -> some View {
        let isSelected = region == selectedRegion
        let count = region.filter(countryDataService.countries).count

        return Button {
            hapticsService.selection()
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedRegion = region
            }
        } label: {
            VStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(color(for: region).opacity(isSelected ? 0.18 : 0.08))
                        .frame(width: 64, height: 64)

                    Image(systemName: region.regionIcon)
                        .font(DesignSystem.Font.iconLarge.weight(.medium))
                        .foregroundStyle(color(for: region))
                }

                VStack(spacing: DesignSystem.Spacing.xxs) {
                    Text(region.displayName)
                        .font(DesignSystem.Font.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)

                    Text("\(count) countries")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }

                Text(description(for: region))
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 34)
            }
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
                                    ? color(for: region).opacity(0.5)
                                    : DesignSystem.Color.cardBackgroundHighlighted,
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    )
            )
        }
        .buttonStyle(PressButtonStyle())
        .animation(.easeInOut(duration: 0.25), value: isSelected)
    }
}

// MARK: - Helpers
private extension RegionCarousel {
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
