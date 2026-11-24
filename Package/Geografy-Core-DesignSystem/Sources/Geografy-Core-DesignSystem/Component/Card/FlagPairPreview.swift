import SwiftUI

/// The long-press preview of a pair of countries or currencies, such as a route or a comparison: both flags large,
/// the pair's name, and the one figure its own screen leads with.
public struct FlagPairPreview: View {
    // MARK: - Properties
    private let leftFlagCode: String
    private let rightFlagCode: String
    private let title: String
    private let subtitle: String?
    private let figure: String?

    // MARK: - Init
    public init(
        leftFlagCode: String,
        rightFlagCode: String,
        title: String,
        subtitle: String? = nil,
        figure: String? = nil
    ) {
        self.leftFlagCode = leftFlagCode
        self.rightFlagCode = rightFlagCode
        self.title = title
        self.subtitle = subtitle
        self.figure = figure
    }

    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                FlagView(countryCode: leftFlagCode, height: DesignSystem.Size.Flag.compact, fixedWidth: true)
                Image(systemName: "arrow.right")
                    .font(DesignSystem.Font.headline)
                    .foregroundStyle(DesignSystem.Color.iconSecondary)
                FlagView(countryCode: rightFlagCode, height: DesignSystem.Size.Flag.compact, fixedWidth: true)
            }
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(title)
                    .font(DesignSystem.Font.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
            }
            if let figure {
                Text(figure)
                    .font(DesignSystem.Font.textStyle(.largeTitle, design: .rounded, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(DesignSystem.Color.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.lg)
    }
}
