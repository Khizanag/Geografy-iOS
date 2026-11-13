import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public struct FeedCard: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public let item: FeedItem
    public let isSaved: Bool
    public let country: Country?
    public let onSave: () -> Void
    public let onCountryTap: (Country) -> Void

    // MARK: - Body
    public var body: some View {
        CardView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                cardHeader
                cardBody
                if let country {
                    cardFooter(country: country)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Subviews
private extension FeedCard {
    var cardHeader: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            categoryChip
            Spacer()
            saveButton
        }
    }

    var categoryChip: some View {
        InfoPill(item.type.label, systemImage: item.icon, style: .tinted(item.color))
    }

    var saveButton: some View {
        Button(action: onSave) {
            Image(systemName: isSaved ? "heart.fill" : "heart")
                .font(DesignSystem.Font.title3)
                .foregroundStyle(isSaved ? DesignSystem.Color.error : DesignSystem.Color.textTertiary)
                .symbolEffect(.bounce, value: reduceMotion ? false : isSaved)
                .scaleEffect(isSaved || reduceMotion ? 1.0 : 0.9)
                .animation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.5), value: isSaved)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isSaved ? "Remove from saved" : "Save")
        .accessibilityAddTraits(isSaved ? .isSelected : [])
    }

    var cardBody: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(item.title)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(item.body)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func cardFooter(country: Country) -> some View {
        Button { onCountryTap(country) } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(countryCode: country.code, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous))
                    .accessibilityHidden(true)
                Text(country.name)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                Spacer()
                Text("Learn More")
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(item.color)
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.micro.weight(.semibold))
                    .foregroundStyle(item.color)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                DesignSystem.Color.cardBackgroundHighlighted,
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}
