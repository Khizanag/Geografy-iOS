import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// How many of a quiz's countries each continent holds: one card of rows, like a grouped list.
struct ContinentCountCard: View {
    // MARK: - Properties
    let countries: [Country]

    // MARK: - Body
    var body: some View {
        RowListCard(counts, dividerInset: DesignSystem.Spacing.md + Self.iconWidth + DesignSystem.Spacing.xs) { count in
            row(count)
        }
    }
}

// MARK: - Subviews
private extension ContinentCountCard {
    static let iconWidth: CGFloat = 24

    func row(_ count: ContinentCount) -> some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: count.continent.icon)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.iconPrimary)
                .frame(width: Self.iconWidth)
                .accessibilityHidden(true)

            Text(count.continent.displayName)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Spacer()

            Text(count.count, format: .number)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .rowListCardRow()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(count.continent.displayName)
        .accessibilityValue(Text("\(count.count) countries", bundle: .module))
    }
}

// MARK: - Counts
private extension ContinentCountCard {
    struct ContinentCount: Identifiable {
        let continent: Country.Continent
        let count: Int

        var id: Country.Continent { continent }
    }

    var counts: [ContinentCount] {
        Dictionary(grouping: countries, by: \.continent)
            .map { ContinentCount(continent: $0.key, count: $0.value.count) }
            .sorted { $0.continent.displayName < $1.continent.displayName }
    }
}
