import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public struct CompareCountrySlot: View {
    // MARK: - Properties
    public let country: Country?
    public let label: String
    public let onTap: () -> Void

    // MARK: - Body
    public var body: some View {
        Button(action: onTap) {
            CardView {
                slotContent
                    .frame(maxWidth: .infinity)
                    .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Subviews
private extension CompareCountrySlot {
    @ViewBuilder
    var slotContent: some View {
        if let country {
            selectedContent(country)
        } else {
            emptyContent
        }
    }

    func selectedContent(_ country: Country) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: country.code, height: DesignSystem.Size.xxl)
                .geoShadow(.subtle)

            Text(country.name)
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(country.continent.displayName)
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var emptyContent: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            IconBadge("plus", size: .medium)

            Text(label)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)

            Text("Tap to select")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
    }
}
