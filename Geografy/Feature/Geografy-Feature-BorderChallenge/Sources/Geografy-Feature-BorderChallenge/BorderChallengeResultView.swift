import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

struct BorderChallengeResultView: View {
    @Environment(\.dismiss) private var dismiss

    let country: Country?
    let found: Int
    let total: Int
    let difficulty: BorderChallengeService.Difficulty
    let secondsUsed: Int
    let onPlayAgain: () -> Void
    let onDone: () -> Void

    var body: some View {
        NavigationStack {
            scrollContent
                .background(DesignSystem.Color.background.ignoresSafeArea())
                .navigationTitle("Results")
                #if !os(tvOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { onDone() }
                    }
                }
                .safeAreaInset(edge: .bottom) { actionButtons }
        }
    }
}

// MARK: - Content
private extension BorderChallengeResultView {
    var scrollContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignSystem.Spacing.xl) {
                gradeSection
                statsGrid
                xpEarnedBadge
                if let country {
                    countryInfoSection(country)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.xxl)
            .readableContentWidth()
        }
    }
}

// MARK: - Grade
private extension BorderChallengeResultView {
    var gradeSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(gradeColor.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: gradeIcon)
                    .font(DesignSystem.IconSize.hero)
                    .foregroundStyle(gradeColor)
                    .symbolEffect(.bounce, value: found)
            }

            Text(gradeTitle)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text(gradeSubtitle)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stats
private extension BorderChallengeResultView {
    var statsGrid: some View {
        CardView {
            HStack(spacing: 0) {
                ResultStatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(found)",
                    label: "Found",
                    color: DesignSystem.Color.success
                )
                ResultStatItem(
                    icon: "globe",
                    value: "\(total)",
                    label: "Total"
                )
                ResultStatItem(
                    icon: "timer",
                    value: formattedTime,
                    label: "Time",
                    color: DesignSystem.Color.blue
                )
                ResultStatItem(
                    icon: "chart.bar.fill",
                    value: "\(accuracyPercent)%",
                    label: "Accuracy",
                    color: DesignSystem.Color.indigo
                )
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - XP Badge
private extension BorderChallengeResultView {
    var xpEarnedBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "star.fill")
                .foregroundStyle(DesignSystem.Color.warning)
            Text("+\(xpEarned) XP")
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Color.warning.opacity(0.12), in: Capsule())
    }
}

// MARK: - Country Info
private extension BorderChallengeResultView {
    func countryInfoSection(_ country: Country) -> some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                FlagView(countryCode: country.code, height: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text(country.name)
                        .font(DesignSystem.Font.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("\(total) bordering countries")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer()
                Text(difficulty.rawValue)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.accent)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xxs)
                    .background(DesignSystem.Color.accent.opacity(0.12), in: Capsule())
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Actions
private extension BorderChallengeResultView {
    var actionButtons: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            GlassButton("Play Again", systemImage: "arrow.clockwise", fullWidth: true) {
                onPlayAgain()
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Helpers
private extension BorderChallengeResultView {
    var accuracyPercent: Int {
        guard total > 0 else { return 0 }
        return Int(Double(found) / Double(total) * 100)
    }

    var formattedTime: String {
        let minutes = secondsUsed / 60
        let seconds = secondsUsed % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }

    var xpEarned: Int {
        BorderChallengeService().xpEarned(found: found, total: total, difficulty: difficulty)
    }

    var gradeIcon: String {
        switch accuracyPercent {
        case 100: "trophy.fill"
        case 80...: "star.fill"
        case 50...: "hand.thumbsup.fill"
        default: "book.fill"
        }
    }

    var gradeTitle: String {
        switch accuracyPercent {
        case 100: "Perfect!"
        case 80...: "Excellent!"
        case 50...: "Good Job!"
        default: "Keep Practicing!"
        }
    }

    var gradeSubtitle: String {
        if let country {
            "You found \(found) of \(total) neighbors of \(country.name)"
        } else {
            "You found \(found) of \(total) neighbors"
        }
    }

    var gradeColor: Color {
        switch accuracyPercent {
        case 100: DesignSystem.Color.warning
        case 80...: DesignSystem.Color.success
        case 50...: DesignSystem.Color.accent
        default: DesignSystem.Color.textSecondary
        }
    }
}
