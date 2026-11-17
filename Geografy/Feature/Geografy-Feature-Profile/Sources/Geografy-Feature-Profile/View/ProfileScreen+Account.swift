#if !os(tvOS)
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - Quiz History
extension ProfileScreen {
    public var quizHistorySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Recent Quizzes")
            RowListCard(
                Array(recentQuizzes.prefix(3)),
                dividerInset: RowListCardLayout.dividerInset(after: RowListCardLayout.iconBadgeWidth)
            ) { record in
                quizHistoryRow(record)
            }
        }
    }
}

// MARK: - Quiz History Subviews
private extension ProfileScreen {
    func quizHistoryRow(_ record: QuizHistoryRecord) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            IconBadge(
                QuizType(rawValue: record.quizType)?.icon ?? "gamecontroller.fill",
                color: DesignSystem.Color.purple,
                size: .small
            )
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
                Text(QuizType(rawValue: record.quizType)?.displayName ?? record.quizType)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(record.completedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xxxs) {
                Text("\(record.correctCount)/\(record.totalCount)")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(scoreColor(accuracy: record.accuracy))
                Text("+\(record.xpEarned) XP")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.warning)
            }
        }
        .rowListCardRow()
        .accessibilityElement(children: .combine)
    }

    func scoreColor(accuracy: Double) -> Color {
        switch accuracy {
        case 0.8...1.0: DesignSystem.Color.success
        case 0.5..<0.8: DesignSystem.Color.warning
        default:        DesignSystem.Color.error
        }
    }
}

// MARK: - Account Section
extension ProfileScreen {
    public var accountSection: some View {
        SettingsGroup("Account") {
            if authService.isGuest {
                Button { coordinator.push(ProfileLocalRoute.signIn) } label: {
                    SettingsNavigationRow(
                        icon: "person.badge.plus",
                        iconColor: DesignSystem.Color.blue,
                        title: "Sign In"
                    )
                }
                .buttonStyle(PressButtonStyle())
            } else {
                Button { showSignOutAlert = true } label: {
                    SettingsActionRow(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: "Sign Out",
                        isDestructive: true
                    )
                }
                .buttonStyle(PressButtonStyle())
                SettingsDivider()
                Button { showDeleteAlert = true } label: {
                    SettingsActionRow(icon: "trash.fill", title: "Delete Account", isDestructive: true)
                }
                .buttonStyle(PressButtonStyle())
            }
        }
    }
}
#endif
