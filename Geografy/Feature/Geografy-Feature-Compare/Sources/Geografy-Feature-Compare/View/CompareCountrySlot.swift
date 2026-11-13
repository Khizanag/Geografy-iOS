import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// One side of the matchup: the picked country in its side's color, or a dashed slot to pick one.
struct CompareCountrySlot: View {
    // MARK: - Properties
    let country: Country?
    let side: CompareSide
    let onPick: () -> Void
    let onClear: () -> Void

    // MARK: - Body
    var body: some View {
        Button(action: onPick) {
            slotContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.md)
                .background { slotBackground }
                .contentShape(.contextMenuPreview, Self.shape)
                .contentShape(Self.shape)
        }
        .buttonStyle(PressButtonStyle())
        .contextMenu {
            if country != nil {
                Button("Change", systemImage: "arrow.triangle.2.circlepath", action: onPick)
                Button("Remove", systemImage: "xmark", role: .destructive, action: onClear)
            }
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(country == nil ? "Chooses a country" : "Changes the country")
        .accessibilityActions {
            if country != nil {
                Button("Remove", action: onClear)
            }
        }
    }
}

// MARK: - Subviews
private extension CompareCountrySlot {
    static let shape = RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.extraLarge, style: .continuous)

    @ViewBuilder
    var slotContent: some View {
        if let country {
            selectedContent(country)
        } else {
            emptyContent
        }
    }

    func selectedContent(_ country: Country) -> some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            FlagView(countryCode: country.code, height: DesignSystem.Size.Flag.compact)
                .geoShadow(.subtle)
                .padding(.bottom, DesignSystem.Spacing.xxs)

            Text(country.name)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(country.continent.displayName)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var emptyContent: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "plus")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(side.color)
                .frame(width: DesignSystem.Size.xl, height: DesignSystem.Size.xl)
                .background(side.color.opacity(0.15), in: Circle())

            Text("Choose a country")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    var slotBackground: some View {
        if country != nil {
            Self.shape
                .fill(DesignSystem.Color.cardBackground)
                .overlay {
                    Self.shape.strokeBorder(side.color.opacity(0.6), lineWidth: 1.5)
                }
        } else {
            Self.shape
                .fill(side.color.opacity(0.06))
                .overlay {
                    Self.shape.strokeBorder(
                        side.color.opacity(0.5),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 5])
                    )
                }
        }
    }

    var accessibilityLabel: String {
        "\(side.title): \(country?.name ?? "not chosen")"
    }
}
