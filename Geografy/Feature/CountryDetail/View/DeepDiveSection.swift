import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - Deep Dive Section
extension CountryDetailScreen {
    @ViewBuilder
    var deepDiveSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Deep Dive", icon: "book.pages")
                .accessibilityAddTraits(.isHeader)
            deepDiveCard
        }
    }
}

// MARK: - Subviews
private extension CountryDetailScreen {
    var deepDiveCard: some View {
        Button {
            activeSheet = .deepDive
        } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.md) {
                    deepDiveIcon
                    deepDiveText
                    Spacer(minLength: 0)
                    chevronIcon
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(PressButtonStyle())
    }

    var deepDiveIcon: some View {
        ZStack {
            Circle()
                .fill(DesignSystem.Color.accent.opacity(0.12))
                .frame(width: DesignSystem.Size.xxl, height: DesignSystem.Size.xxl)
            Image(systemName: "book.pages.fill")
                .font(DesignSystem.Font.iconSmall.weight(.medium))
                .foregroundStyle(DesignSystem.Color.accent)
        }
        .accessibilityHidden(true)
    }

    var deepDiveText: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text("Culture, History & More")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                PremiumBadge()
            }
            Text("Explore phrases, timeline, economy and cultural highlights")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .lineLimit(2)
        }
    }

    var chevronIcon: some View {
        Image(systemName: "chevron.right")
            .font(DesignSystem.Font.caption)
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .accessibilityHidden(true)
    }
}
