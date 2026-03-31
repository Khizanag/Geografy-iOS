import SwiftUI
import Accessibility
import GeografyDesign

struct DailyChallengeResultView: View {
    @Environment(Navigator.self) private var coordinator
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let score: Int
    let maxScore: Int
    let challengeType: DailyChallengeType
    let timeSpent: Double
    let streak: Int

    @State private var animatedScore: Int = 0
    @State private var showShareCard = false
    @State private var blobAnimating = false

    var body: some View {
        resultContent
            .navigationTitle("Results")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .onAppear { animateScore() }
            .sheet(isPresented: $showShareCard) {
                shareCardSheet
            }
    }
}

// MARK: - Content
private extension DailyChallengeResultView {
    var resultContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                scoreSection
                statsRow
                streakBadge
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
            .padding(.horizontal, DesignSystem.Spacing.md)
        }
        .safeAreaInset(edge: .bottom) { actionButtons }
        .background { ambientBlobs }
        .background(DesignSystem.Color.background.ignoresSafeArea())
    }
}

// MARK: - Score Section
private extension DailyChallengeResultView {
    var scoreSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ScoreRingView(progress: Double(score) / Double(maxScore))
                .accessibilityLabel("Score: \(score) out of \(maxScore) points")
            Text(scoreMessage)
                .font(DesignSystem.Font.title2)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text("\(animatedScore) / \(maxScore) points")
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.accent)
                .contentTransition(.numericText())
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }
}

// MARK: - Stats Row
private extension DailyChallengeResultView {
    var statsRow: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            CardView {
                ResultStatItem(
                    icon: "star.fill",
                    value: "\(score)",
                    label: "Score"
                )
                .padding(DesignSystem.Spacing.sm)
            }
            CardView {
                ResultStatItem(
                    icon: "clock.fill",
                    value: formattedTime,
                    label: "Time",
                    color: DesignSystem.Color.warning
                )
                .padding(DesignSystem.Spacing.sm)
            }
            CardView {
                ResultStatItem(
                    icon: challengeType.iconName,
                    value: challengeType.title,
                    label: "Type",
                    color: DesignSystem.Color.indigo
                )
                .padding(DesignSystem.Spacing.sm)
            }
        }
    }
}

// MARK: - Streak Badge
private extension DailyChallengeResultView {
    var streakBadge: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Color.orange.opacity(0.15))
                        .frame(
                            width: DesignSystem.Size.xl,
                            height: DesignSystem.Size.xl
                        )
                    Image(systemName: "flame.fill")
                        .font(DesignSystem.Font.title2)
                        .foregroundStyle(DesignSystem.Color.orange)
                }
                .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Challenge Streak")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("\(streak) day\(streak == 1 ? "" : "s") in a row")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }
                Spacer()
            }
            .padding(DesignSystem.Spacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Challenge Streak: \(streak) day\(streak == 1 ? "" : "s") in a row")
    }
}

// MARK: - Action Buttons
private extension DailyChallengeResultView {
    var actionButtons: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            shareButton
            doneButton
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }

    var shareButton: some View {
        Button { showShareCard = true } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "square.and.arrow.up")
                    .font(DesignSystem.Font.headline)
                Text("Share Result")
                    .font(DesignSystem.Font.headline)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .buttonStyle(.glass)
    }

    var doneButton: some View {
        Button { coordinator.dismiss() } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "checkmark")
                    .font(DesignSystem.Font.headline)
                Text("Done")
                    .font(DesignSystem.Font.headline)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .buttonStyle(.glass)
    }

    var shareCardSheet: some View {
        DailyChallengeShareCard(
            score: score,
            maxScore: maxScore,
            challengeType: challengeType,
            streak: streak,
            date: .now
        )
    }
}

// MARK: - Background
private extension DailyChallengeResultView {
    var ambientBlobs: some View {
        ZStack {
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.accent.opacity(0.22),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 420, height: 320)
                .blur(radius: 36)
                .offset(x: -80, y: -60)
                .scaleEffect(blobAnimating ? 1.10 : 0.90)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 6).repeatForever(autoreverses: true),
            value: blobAnimating
        )
        .onAppear {
            blobAnimating = true
        }
    }
}

// MARK: - Helpers
private extension DailyChallengeResultView {
    var scoreMessage: String {
        let accuracy = Double(score) / Double(maxScore)
        if accuracy >= 0.9 {
            return "Outstanding!"
        } else if accuracy >= 0.7 {
            return "Great Job!"
        } else if accuracy >= 0.5 {
            return "Good Effort!"
        } else {
            return "Keep Trying!"
        }
    }

    var formattedTime: String {
        let minutes = Int(timeSpent) / 60
        let seconds = Int(timeSpent) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }

    func animateScore() {
        animatedScore = score
        AccessibilityNotification.Announcement("\(scoreMessage) \(score) out of \(maxScore) points").post()
    }
}
