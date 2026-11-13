import Geografy_Core_Common
import SwiftUI

/// A compact country row: flag, name, an optional subtitle, and any trailing view.
public struct CountryListRow<Trailing: View>: View {
    // MARK: - Properties
    private let country: Country
    private let subtitle: String?
    private let trailing: Trailing

    // MARK: - Init
    public init(country: Country, subtitle: String? = nil, @ViewBuilder trailing: () -> Trailing) {
        self.country = country
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    // MARK: - Body
    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: country.code, height: DesignSystem.Size.Flag.inline, fixedWidth: true)
            VStack(alignment: .leading, spacing: 2) {
                Text(country.name)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)
                if let subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            trailing
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

public extension CountryListRow where Trailing == EmptyView {
    init(country: Country, subtitle: String? = nil) {
        self.init(country: country, subtitle: subtitle) { EmptyView() }
    }
}

/// The trailing chevron on rows that navigate.
public struct RowChevron: View {
    public init() {}

    public var body: some View {
        Image(systemName: "chevron.right")
            .font(DesignSystem.Font.caption)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .accessibilityHidden(true)
    }
}
