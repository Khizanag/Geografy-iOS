import SwiftUI

struct CountryRowView: View {
    @Environment(HapticsService.self) private var hapticsService
    @Environment(PronunciationService.self) private var pronunciationService

    let country: Country
    let isFavorite: Bool
    var showFlag: Bool = true
    var showCapital: Bool = true
    var showStats: Bool = true
    var showContinent: Bool = true
    var showSpeaker: Bool = false
    var onFavoriteTap: (() -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            accentStripe
            contentRow
        }
        .background(DesignSystem.Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
        .countryContextMenu(country)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(country.name), \(country.continent.displayName)")
        .accessibilityHint("Double tap to view details")
    }
}

// MARK: - Subviews
private extension CountryRowView {
    var accentStripe: some View {
        let codeValue = country.code.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        let color = DesignSystem.Color.mapColors[codeValue % DesignSystem.Color.mapColors.count]
        return color
            .frame(width: 3)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: DesignSystem.CornerRadius.medium,
                    bottomLeadingRadius: DesignSystem.CornerRadius.medium,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
            )
    }

    var contentRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if showFlag {
                FlagView(countryCode: country.code, height: 36)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    .frame(width: 56, alignment: .center)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(country.name)
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(2)

                if showCapital {
                    capitalLabel
                }

                if showStats {
                    statsRow
                }
            }

            Spacer(minLength: 0)

            favoriteIcon
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .padding(.trailing, DesignSystem.Spacing.sm)
        .padding(.leading, DesignSystem.Spacing.sm)
        .overlay(alignment: .topTrailing) {
            if showContinent {
                continentBadge
                    .padding(.top, DesignSystem.Spacing.xs)
                    .padding(.trailing, DesignSystem.Spacing.xs)
            }
        }
    }

    var capitalLabel: some View {
        HStack(spacing: 3) {
            Image(systemName: "mappin.and.ellipse")
                .font(DesignSystem.Font.pico.bold())
                .foregroundStyle(DesignSystem.Color.accent)
            Text(country.allCapitals.map(\.name).joined(separator: " · "))
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
    }

    var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            HStack(spacing: 3) {
                Image(systemName: "map")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                Text(country.area.formatArea())
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }

            Text("·")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)

            HStack(spacing: 3) {
                Image(systemName: "person.2")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
                Text(country.population.formatPopulation())
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
        }
    }

    var continentBadge: some View {
        Text(country.continent.displayName)
            .font(DesignSystem.Font.nano.weight(.semibold))
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(DesignSystem.Color.cardBackgroundHighlighted, in: Capsule())
    }

    @ViewBuilder
    var favoriteIcon: some View {
        if let onFavoriteTap {
            Button {
                hapticsService.impact(.light)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    onFavoriteTap()
                }
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(isFavorite ? DesignSystem.Color.error : DesignSystem.Color.textTertiary)
                    .symbolEffect(.bounce, value: isFavorite)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } else {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(isFavorite ? DesignSystem.Color.error : DesignSystem.Color.textTertiary)
        }
    }
}
