import SwiftUI

// MARK: - Level Progress Section
extension ProfileScreen {
    var levelProgressSection: some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack(alignment: .center, spacing: DesignSystem.Spacing.md) {
                    levelRing
                    levelInfo
                    Spacer()
                    xpBadge
                }
                xpProgressView
            }
            .padding(DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Level Progress Subviews
private extension ProfileScreen {
    var levelRing: some View {
        ZStack {
            Circle()
                .stroke(DesignSystem.Color.cardBackgroundHighlighted, lineWidth: 5)
                .frame(width: 64, height: 64)

            Circle()
                .trim(from: 0, to: xpService.progressFraction)
                .stroke(
                    LinearGradient(
                        colors: [DesignSystem.Color.accent, DesignSystem.Color.indigo],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: xpService.progressFraction)

            Text("\(xpService.currentLevel.level)")
                .font(DesignSystem.Font.roundedSubheadline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Level \(xpService.currentLevel.level)")
        .accessibilityValue("\(Int(xpService.progressFraction * 100)) percent progress")
    }

    var levelInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(xpService.currentLevel.title)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            if xpService.currentLevel.level < 10 {
                Text("\(xpService.xpInCurrentLevel) / \(xpService.xpRequiredForNextLevel) XP to next level")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            } else {
                Text("Maximum level reached!")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.accent)
            }
        }
    }

    var xpBadge: some View {
        VStack(spacing: 2) {
            Text("\(xpService.totalXP)")
                .font(DesignSystem.Font.roundedSmall)
                .foregroundStyle(DesignSystem.Color.accent)
            Text("Total XP")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(xpService.totalXP) total XP")
    }

    var xpProgressView: some View {
        XPProgressBar(
            currentLevelNumber: xpService.currentLevel.level,
            nextLevelNumber: xpService.currentLevel.level < 10 ? xpService.currentLevel.level + 1 : nil,
            xpInCurrentLevel: xpService.xpInCurrentLevel,
            xpRequiredForNextLevel: xpService.xpRequiredForNextLevel,
            progressFraction: xpService.progressFraction
        )
    }
}
