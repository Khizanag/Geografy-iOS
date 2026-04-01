import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

public struct DailyChallengeShareCard: View {
    public let score: Int
    public let maxScore: Int
    public let challengeType: DailyChallengeType
    public let streak: Int
    public let date: Date

    @State private var renderedImage: Image?

    public var body: some View {
        mainContent
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Share")
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Subviews
private extension DailyChallengeShareCard {
    var mainContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            shareCardPreview
            shareActions
        }
    }
}

// MARK: - Share Card Preview
private extension DailyChallengeShareCard {
    @MainActor
    var shareCardPreview: some View {
        cardContent
            .clipShape(
                RoundedRectangle(
                    cornerRadius: DesignSystem.CornerRadius.large
                )
            )
            .geoShadow(.elevated)
    }

    var cardContent: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            cardHeader
            scoreDisplay
            cardStatsRow
            cardFooter
        }
        .padding(DesignSystem.Spacing.lg)
        .background(cardGradient)
    }

    var cardHeader: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "globe.americas.fill")
                    .font(DesignSystem.Font.headline)
                Text("Geografy")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.bold)
            }
            .foregroundStyle(DesignSystem.Color.onAccent)

            Text("Daily Challenge")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.8))
        }
    }

    var scoreDisplay: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text("\(score)")
                .font(DesignSystem.Font.roundedHero)
                .foregroundStyle(DesignSystem.Color.onAccent)
            Text("out of \(maxScore)")
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.7))
        }
    }

    var cardStatsRow: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            cardStat(
                icon: challengeType.iconName,
                value: challengeType.title
            )
            cardStat(
                icon: "flame.fill",
                value: "\(streak) day streak"
            )
        }
    }

    func cardStat(icon: String, value: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: icon)
                .font(DesignSystem.Font.caption2)
            Text(value)
                .font(DesignSystem.Font.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.9))
    }

    var cardFooter: some View {
        Text(date.formatted(date: .abbreviated, time: .omitted))
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.onAccent.opacity(0.6))
    }

    var cardGradient: some View {
        LinearGradient(
            colors: [
                DesignSystem.Color.accent,
                DesignSystem.Color.indigo,
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Share Actions
private extension DailyChallengeShareCard {
    var shareActions: some View {
        #if !os(tvOS)
        ShareLink(
            item: shareText,
            preview: SharePreview("Geografy Daily Challenge")
        ) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "square.and.arrow.up")
                    .font(DesignSystem.Font.headline)
                Text("Share")
                    .font(DesignSystem.Font.headline)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .buttonStyle(.glass)
        #else
        EmptyView()
        #endif
    }

    var shareText: String {
        let emoji = scoreEmoji
        let blocks = scoreBlocks
        return """
        \(emoji) Geografy Daily Challenge
        \(challengeType.title) — \(date.formatted(date: .abbreviated, time: .omitted))

        Score: \(score)/\(maxScore) \(blocks)
        Streak: \(streak) day\(streak == 1 ? "" : "s") 🔥

        geografy.app
        """
    }

    var scoreEmoji: String {
        let ratio = Double(score) / Double(maxScore)
        if ratio >= 0.9 { return "🏆" }
        if ratio >= 0.7 { return "⭐" }
        if ratio >= 0.5 { return "👍" }
        return "🌍"
    }

    var scoreBlocks: String {
        let filled = Int((Double(score) / Double(maxScore)) * 10)
        let empty = 10 - filled
        return String(repeating: "🟩", count: filled)
            + String(repeating: "⬛", count: empty)
    }
}
