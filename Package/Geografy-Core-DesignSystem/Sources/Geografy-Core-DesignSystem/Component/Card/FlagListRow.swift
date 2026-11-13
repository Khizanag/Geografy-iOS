import SwiftUI

/// A compact row led by a flag: a title, an optional subtitle, and any trailing view.
/// Anything a flag stands for fits: a country, a currency, a language.
public struct FlagListRow<Trailing: View>: View {
    // MARK: - Properties
    private let flagCode: String
    private let title: String
    private let subtitle: String?
    private let trailing: Trailing

    // MARK: - Init
    public init(flagCode: String, title: String, subtitle: String? = nil, @ViewBuilder trailing: () -> Trailing) {
        self.flagCode = flagCode
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing()
    }

    // MARK: - Body
    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: flagCode, height: DesignSystem.Size.Flag.inline, fixedWidth: true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
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

public extension FlagListRow where Trailing == EmptyView {
    init(flagCode: String, title: String, subtitle: String? = nil) {
        self.init(flagCode: flagCode, title: title, subtitle: subtitle) { EmptyView() }
    }
}
