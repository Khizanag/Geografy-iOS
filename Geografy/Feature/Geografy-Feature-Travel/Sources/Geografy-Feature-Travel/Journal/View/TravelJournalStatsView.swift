import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import SwiftUI

public struct TravelJournalStatsView: View {
    // MARK: - Properties
    public let totalEntries: Int
    public let totalPhotos: Int
    public let uniqueCountries: Int
    public let averageRating: Double
    public let favoriteCountryCode: String?

    // MARK: - Body
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            CardView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    headerRow
                    if let favoriteCountryCode {
                        favoriteRow(countryCode: favoriteCountryCode)
                    }
                }
                .padding(DesignSystem.Spacing.md)
            }
            .accessibilityElement(children: .combine)
            statsRow
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
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("Journal Stats")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("\(totalEntries) entries written")
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
                    .font(DesignSystem.Font.micro)
                    .foregroundStyle(
                        DesignSystem.Color.warning
                    )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Average rating \(formattedRating) of 5 stars")
    }

    var statsRow: some View {
        StatTileRow {
            StatTile(value: "\(uniqueCountries)", label: "Countries", icon: "globe")
            StatTile(value: "\(totalPhotos)", label: "Photos", icon: "photo.fill")
            StatTile(value: formattedRating, label: "Avg Rating", icon: "star.fill")
        }
    }

    func favoriteRow(countryCode: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "heart.fill")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.error)
                .accessibilityHidden(true)
            Text("Favorite Destination")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            Spacer(minLength: 0)
            FlagView(countryCode: countryCode, height: 18)
                .clipShape(
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                )
                .accessibilityLabel(Locale.current.localizedString(forRegionCode: countryCode) ?? countryCode)
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
