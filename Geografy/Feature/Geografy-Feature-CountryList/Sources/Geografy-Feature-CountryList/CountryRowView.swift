import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

public struct CountryRowView: View {
    // MARK: - Properties
    @Environment(HapticsService.self) private var hapticsService
    @Environment(PronunciationService.self) private var pronunciationService
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let country: Country
    public let isFavorite: Bool
    public var showFlag: Bool = true
    public var showCapital: Bool = true
    public var showArea: Bool = true
    public var showPopulation: Bool = true
    public var showContinent: Bool = true
    public var showSpeaker: Bool = false
    public var onFavoriteTap: (() -> Void)?

    // MARK: - Init
    public init(
        country: Country,
        isFavorite: Bool,
        showFlag: Bool = true,
        showCapital: Bool = true,
        showArea: Bool = true,
        showPopulation: Bool = true,
        showContinent: Bool = true,
        showSpeaker: Bool = false,
        onFavoriteTap: (() -> Void)? = nil
    ) {
        self.country = country
        self.isFavorite = isFavorite
        self.showFlag = showFlag
        self.showCapital = showCapital
        self.showArea = showArea
        self.showPopulation = showPopulation
        self.showContinent = showContinent
        self.showSpeaker = showSpeaker
        self.onFavoriteTap = onFavoriteTap
    }

    // MARK: - Body
    public var body: some View {
        CardView {
            HStack(spacing: 0) {
                accentStripe
                contentRow
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge, style: .continuous)
                .strokeBorder(DesignSystem.Color.dividerSubtle, lineWidth: 1)
        )
        .hoverEffect(.lift)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view details")
        .accessibilityValue(isFavorite ? "Favorite" : "")
        .accessibilityActions {
            if onFavoriteTap != nil {
                Button(favoriteActionLabel) { toggleFavorite() }
            }
        }
    }
}

// MARK: - Subviews
private extension CountryRowView {
    var accentStripe: some View {
        let codeValue = country.code.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        let color = DesignSystem.Color.mapColors[codeValue % DesignSystem.Color.mapColors.count]
        return color
            .frame(width: 3)
    }

    // At accessibility text sizes the row stacks: flag on top, then each fact on its own line.
    var isStacked: Bool {
        dynamicTypeSize.isAccessibilitySize
    }

    var contentRow: some View {
        HStack(alignment: isStacked ? .top : .center, spacing: DesignSystem.Spacing.sm) {
            if showFlag, !isStacked {
                flag
            }

            VStack(alignment: .leading, spacing: 3) {
                if isStacked {
                    stackedTopLine
                }
                nameLine

                if showCapital {
                    capitalLabel
                }

                if showArea || showPopulation {
                    statsRow
                }
            }

            Spacer(minLength: 0)

            if !isStacked {
                favoriteIcon
            }
        }
        .padding(DesignSystem.Spacing.sm)
    }

    // Stacked rows put the heart beside the flag, so the name below gets the row's full width.
    var stackedTopLine: some View {
        HStack(alignment: .top) {
            if showFlag {
                flag
            }
            Spacer(minLength: 0)
            favoriteIcon
        }
    }

    var capitalLabel: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(DesignSystem.Font.pico.bold())
                .foregroundStyle(DesignSystem.Color.accent)
                .accessibilityHidden(true)
            Text(country.allCapitals.map(\.name).joined(separator: " · "))
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(1)
        }
    }

    var flag: some View {
        FlagView(countryCode: country.code, height: 36, fixedWidth: true)
            .geoShadow(.subtle)
    }

    // The continent rides beside the name while both fit on one line; a long name gets the full width
    // and the badge moves under it, so the name never truncates.
    @ViewBuilder
    var nameLine: some View {
        if isStacked || !showContinent {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                nameText
                if showContinent {
                    continentBadge
                }
            }
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline, spacing: DesignSystem.Spacing.xs) {
                    nameText
                        .fixedSize()
                    continentBadge
                        .fixedSize()
                }
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    nameText
                    continentBadge
                        .fixedSize()
                }
            }
        }
    }

    var nameText: some View {
        Text(country.name)
            .font(DesignSystem.Font.headline)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }

    // Side by side when both fit on one line; otherwise each stat takes its own line, never breaking mid-value.
    @ViewBuilder
    var statsRow: some View {
        if isStacked {
            statsColumn
        } else {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: DesignSystem.Spacing.xxs) {
                    if showArea {
                        areaStat
                    }
                    if showArea, showPopulation {
                        Text("·")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                    }
                    if showPopulation {
                        populationStat
                    }
                }
                statsColumn
            }
        }
    }

    var statsColumn: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            if showArea {
                areaStat
            }
            if showPopulation {
                populationStat
            }
        }
    }

    var areaStat: some View {
        stat(icon: "map", value: country.area.formatArea())
    }

    var populationStat: some View {
        stat(icon: "person.2", value: country.population.formatPopulation())
    }

    func stat(icon: String, value: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .accessibilityHidden(true)
            Text(value)
                .fixedSize(horizontal: !isStacked, vertical: false)
        }
        .font(DesignSystem.Font.caption2)
        .foregroundStyle(DesignSystem.Color.textSecondary)
    }

    var continentBadge: some View {
        InfoPill(country.continent.displayName)
    }

    @ViewBuilder
    var favoriteIcon: some View {
        if onFavoriteTap != nil {
            Button(action: toggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(isFavorite ? DesignSystem.Color.error : DesignSystem.Color.textSecondary)
                    .symbolEffect(.bounce, value: reduceMotion ? false : isFavorite)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(favoriteActionLabel)
        } else {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(isFavorite ? DesignSystem.Color.error : DesignSystem.Color.textSecondary)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Actions
private extension CountryRowView {
    var accessibilityLabel: String {
        var parts = [country.name, country.continent.displayName]
        if showCapital {
            parts.append("Capital \(country.allCapitals.map(\.name).formatted(.list(type: .and)))")
        }
        return parts.joined(separator: ", ")
    }

    var favoriteActionLabel: String {
        isFavorite ? "Remove from Favorites" : "Add to Favorites"
    }

    func toggleFavorite() {
        guard let onFavoriteTap else { return }
        hapticsService.impact(.light)
        withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.6)) {
            onFavoriteTap()
        }
    }
}
