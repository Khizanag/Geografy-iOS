import SwiftUI

/// Two flags and a title, such as "France vs Germany" or "Paris → Tokyo": a ready-made pair to open.
public struct FlagPairRow: View {
    // MARK: - Properties
    private let leftFlagCode: String
    private let rightFlagCode: String
    private let title: String
    private let subtitle: String?
    private let accessibilityText: String
    private let action: () -> Void

    // MARK: - Init
    public init(
        leftFlagCode: String,
        rightFlagCode: String,
        title: String,
        subtitle: String? = nil,
        accessibilityLabel: String? = nil,
        action: @escaping () -> Void
    ) {
        self.leftFlagCode = leftFlagCode
        self.rightFlagCode = rightFlagCode
        self.title = title
        self.subtitle = subtitle
        self.accessibilityText = accessibilityLabel ?? title
        self.action = action
    }

    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                HStack(spacing: DesignSystem.Spacing.xxs) {
                    FlagView(countryCode: leftFlagCode, height: DesignSystem.Size.Flag.inline, fixedWidth: true)
                    FlagView(countryCode: rightFlagCode, height: DesignSystem.Size.Flag.inline, fixedWidth: true)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                        .multilineTextAlignment(.leading)
                    if let subtitle {
                        Text(subtitle)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                }

                Spacer(minLength: 0)
                RowChevron()
            }
            .rowListCardRow()
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }
}
