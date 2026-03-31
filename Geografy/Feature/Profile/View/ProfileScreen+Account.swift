#if !os(tvOS)
import SwiftUI
import GeografyCore
import GeografyDesign

// MARK: - Quiz History
extension ProfileScreen {
    var quizHistorySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Recent Quizzes")
            VStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(recentQuizzes.prefix(3), id: \.id) { record in
                    quizHistoryRow(record)
                }
            }
        }
    }
}

// MARK: - Quiz History Subviews
private extension ProfileScreen {
    func quizHistoryRow(_ record: QuizHistoryRecord) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.purple.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: QuizType(rawValue: record.quizType)?.icon ?? "gamecontroller.fill")
                    .font(DesignSystem.Font.iconXS)
                    .foregroundStyle(DesignSystem.Color.purple)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(QuizType(rawValue: record.quizType)?.displayName ?? record.quizType)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(record.completedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(record.correctCount)/\(record.totalCount)")
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(scoreColor(accuracy: record.accuracy))
                Text("+\(record.xpEarned) XP")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
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

// MARK: - Premium Banner
extension ProfileScreen {
    var premiumBannerSection: some View {
        Button { activeSheet = .paywall } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Color.accent.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "crown.fill")
                        .font(DesignSystem.Font.iconSmall)
                        .foregroundStyle(DesignSystem.Color.accent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Get Geografy Premium")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("Unlock all quiz types, advanced stats & more")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                LinearGradient(
                    colors: [
                        DesignSystem.Color.accent.opacity(0.12),
                        DesignSystem.Color.accent.opacity(0.05),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            )
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                    .strokeBorder(DesignSystem.Color.accent.opacity(0.25), lineWidth: 1)
            }
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Account Section
extension ProfileScreen {
    var accountSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeaderView(title: "Account")
            VStack(spacing: DesignSystem.Spacing.xs) {
                if authService.isGuest {
                    signInRow
                } else {
                    signOutRow
                }
                if !authService.isGuest {
                    deleteAccountRow
                }
            }
        }
    }
}

// MARK: - Account Subviews
private extension ProfileScreen {
    var signInRow: some View {
        Button {
            hapticsService.impact(.medium)
            activeSheet = .signIn
        } label: {
            accountRowLabel(
                icon: "person.badge.plus.fill",
                title: "Sign In",
                color: DesignSystem.Color.accent
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var signOutRow: some View {
        Button {
            hapticsService.impact(.medium)
            authService.signOut()
        } label: {
            accountRowLabel(
                icon: "arrow.right.square.fill",
                title: "Sign Out",
                color: DesignSystem.Color.textSecondary
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var deleteAccountRow: some View {
        Button {
            hapticsService.impact(.heavy)
            showDeleteAlert = true
        } label: {
            accountRowLabel(
                icon: "trash.fill",
                title: "Delete Account",
                color: DesignSystem.Color.error
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    func accountRowLabel(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(DesignSystem.Font.iconXS)
                    .foregroundStyle(color)
            }
            Text(title)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
            Spacer()
            Image(systemName: "chevron.right")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
    }
}
#endif
