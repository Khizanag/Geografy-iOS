import Geografy_Core_DesignSystem
import SwiftUI

struct QuickStatsRow: View {
    // MARK: - Properties
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let streakDays: Int
    let level: Int
    let countriesExplored: Int
    let onStreakTap: () -> Void
    let onLevelTap: () -> Void
    let onCountriesTap: () -> Void

    // MARK: - Body
    var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.sm))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.sm))
        return layout {
            statPill(
                icon: "flame.fill",
                value: "\(streakDays)",
                label: String(localized: "streak"),
                color: DesignSystem.Color.orange,
                action: onStreakTap
            )

            statPill(
                icon: "star.fill",
                value: String(localized: "Lv. \(level)"),
                label: String(localized: "level"),
                color: DesignSystem.Color.accent,
                action: onLevelTap
            )

            statPill(
                icon: "globe.americas.fill",
                value: "\(countriesExplored)",
                label: String(localized: "explored"),
                color: DesignSystem.Color.success,
                action: onCountriesTap
            )
        }
    }
}

// MARK: - Subviews
private extension QuickStatsRow {
    func statPill(
        icon: String,
        value: String,
        label: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            CardView(cornerRadius: DesignSystem.CornerRadius.medium) {
                VStack(spacing: DesignSystem.Spacing.xxs) {
                    HStack(spacing: DesignSystem.Spacing.xxs) {
                        Image(systemName: icon)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(color)
                            .accessibilityHidden(true)

                        Text(value)
                            .font(DesignSystem.Font.caption.weight(.semibold))
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                    }

                    Text(label)
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .padding(.horizontal, DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel("\(label): \(value)")
    }
}
