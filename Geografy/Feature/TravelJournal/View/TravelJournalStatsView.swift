import SwiftUI

struct TravelJournalStatsView: View {
    let totalEntries: Int
    let totalPhotos: Int
    let uniqueCountries: Int
    let averageRating: Double
    let favoriteCountryCode: String?

    var body: some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.extraLarge) {
            VStack(spacing: DesignSystem.Spacing.md) {
                headerRow
                statsPills
                if let favoriteCountryCode {
                    favoriteRow(countryCode: favoriteCountryCode)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews

private extension TravelJournalStatsView {
    var headerRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "book.closed.fill")
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text("Journal Stats")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("\(totalEntries) \(totalEntries == 1 ? "entry" : "entries") written")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer(minLength: 0)
            starsDisplay
        }
    }

    var starsDisplay: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: starImageName(for: star))
                    .font(.system(size: 10))
                    .foregroundStyle(
                        DesignSystem.Color.warning
                    )
            }
        }
    }

    var statsPills: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            statPill(
                value: "\(uniqueCountries)",
                label: "Countries",
                icon: "globe"
            )
            statPill(
                value: "\(totalPhotos)",
                label: "Photos",
                icon: "photo.fill"
            )
            statPill(
                value: formattedRating,
                label: "Avg Rating",
                icon: "star.fill"
            )
        }
    }

    func statPill(
        value: String,
        label: String,
        icon: String
    ) -> some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(DesignSystem.Color.accent)
            Text(value)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(label)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            DesignSystem.Color.cardBackgroundHighlighted,
            in: RoundedRectangle(
                cornerRadius: DesignSystem.CornerRadius.medium
            )
        )
    }

    func favoriteRow(countryCode: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "heart.fill")
                .font(.system(size: 12))
                .foregroundStyle(DesignSystem.Color.error)
            Text("Favorite Destination")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer(minLength: 0)
            FlagView(countryCode: countryCode, height: 18)
                .clipShape(
                    RoundedRectangle(cornerRadius: 3)
                )
        }
    }
}

// MARK: - Helpers

private extension TravelJournalStatsView {
    var formattedRating: String {
        guard averageRating > 0 else { return "-" }
        return String(format: "%.1f", averageRating)
    }

    func starImageName(for position: Int) -> String {
        let filled = Int(averageRating.rounded())
        if position <= filled {
            return "star.fill"
        }
        return "star"
    }
}
