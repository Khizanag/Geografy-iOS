import SwiftUI
import GeografyDesign

struct HomeStreakCard: View {
    @Environment(HapticsService.self) private var hapticsService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let streak: Int
    let isAtRisk: Bool
    let onStartQuiz: () -> Void

    @State private var isPulsing = false

    var body: some View {
        cardContent
            .onAppear {
                if isAtRisk {
                    isPulsing = true
                }
            }
            .onChange(of: isAtRisk) { _, newValue in
                isPulsing = newValue
            }
    }
}

// MARK: - Subviews
private extension HomeStreakCard {
    var cardContent: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                streakIcon
                streakInfo
                Spacer()
                quizButton
            }
            .padding(DesignSystem.Spacing.md)
        }
    }

    var streakIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            isAtRisk
                                ? DesignSystem.Color.orange.opacity(0.4)
                                : DesignSystem.Color.orange.opacity(0.25),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: isAtRisk ? 36 : 32
                    )
                )
                .frame(width: 56, height: 56)
                .scaleEffect(isPulsing ? 1.3 : 1.0)
                .animation(
                    isPulsing && !reduceMotion
                        ? .easeInOut(duration: 1.2).repeatForever(autoreverses: true)
                        : .default,
                    value: isPulsing
                )

            Text(streak > 0 ? "🔥" : "💤")
                .font(DesignSystem.Font.iconLarge)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .animation(
                    isPulsing && !reduceMotion
                        ? .easeInOut(duration: 1.2).repeatForever(autoreverses: true)
                        : .default,
                    value: isPulsing
                )
        }
    }

    var streakInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(streakTitle)
                .font(DesignSystem.Font.headline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(streakSubtitle)
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    var quizButton: some View {
        Button {
            hapticsService.impact(.medium)
            onStartQuiz()
        } label: {
            Text("Play")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.onAccent)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(DesignSystem.Color.accent, in: Capsule())
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Helpers
private extension HomeStreakCard {
    var streakTitle: String {
        if streak == 0 {
            "Start your streak"
        } else if isAtRisk {
            "\(streak) day streak at risk!"
        } else {
            "\(streak) day streak!"
        }
    }

    var streakSubtitle: String {
        if streak == 0 {
            "Play a quiz to begin"
        } else if isAtRisk {
            "Play now to keep it alive"
        } else {
            "Keep exploring to maintain it"
        }
    }
}
