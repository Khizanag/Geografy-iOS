import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - Prompt
/// The country to find, the round, the running score, and a dot per round colored by how it went.
struct PinDropPromptCard: View {
    @Environment(\.locale) private var locale

    let country: Country
    let roundIndex: Int
    let roundCount: Int
    let totalScore: Int
    let ratings: [PinDropScore.Rating]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                EyebrowLabel("Find", color: PinDropStyle.gameColor)
                Spacer()
                QuestionCounterPill(current: roundIndex + 1, total: roundCount)
            }
            HStack(spacing: DesignSystem.Spacing.sm) {
                countryName
                Spacer(minLength: DesignSystem.Spacing.sm)
                score
            }
            progressDots
        }
        .padding(DesignSystem.Spacing.md)
        .glassEffect(.regular, in: .rect(cornerRadius: DesignSystem.CornerRadius.extraLarge))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Find \(country.name)"))
        .accessibilityValue(Text("Round \(roundIndex + 1) of \(roundCount), \(totalScore) points"))
    }

    private var countryName: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            FlagView(countryCode: country.code, height: 22, isOutlined: true)
            Text(country.name)
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .id(country.code)
        .transition(.push(from: .bottom).combined(with: .opacity))
    }

    private var score: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(verbatim: PinDropStyle.points(Double(totalScore), locale: locale))
                .font(DesignSystem.Font.title3)
                .fontWeight(.bold)
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(totalScore)))
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text("points")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    private var progressDots: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            ForEach(0..<roundCount, id: \.self) { index in
                Capsule()
                    .fill(dotColor(at: index))
                    .frame(height: 5)
                    .frame(maxWidth: index == roundIndex ? .infinity : nil)
                    .frame(width: index == roundIndex ? nil : 14)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.snappy, value: roundIndex)
    }

    private func dotColor(at index: Int) -> Color {
        if ratings.indices.contains(index) { return ratings[index].color }
        return index == roundIndex
            ? PinDropStyle.gameColor
            : DesignSystem.Color.textTertiary.opacity(DesignSystem.Opacity.soft)
    }
}

// MARK: - Reveal
/// How the round went: the rating, the points counting up, the distance, and any bonuses.
struct PinDropRevealCard: View {
    @Environment(\.locale) private var locale
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let result: PinDropGame.Result
    let isLastRound: Bool
    /// The other player, in a match, while they still have to lock in this round.
    var waitingFor: String?
    let onNext: () -> Void

    @State private var isCounted = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            header
            chips
            if let waitingFor {
                GlassButton(
                    "Waiting for \(waitingFor)…",
                    systemImage: "hourglass",
                    role: .secondary,
                    fullWidth: true
                ) {}
                    .disabled(true)
            } else {
                GlassButton(
                    isLastRound ? "See Results" : "Next Round",
                    systemImage: isLastRound ? "flag.checkered" : "arrow.right",
                    fullWidth: true,
                    action: onNext
                )
            }
        }
        .padding(DesignSystem.Spacing.md)
        .glassEffect(.regular, in: .rect(cornerRadius: DesignSystem.CornerRadius.extraLarge))
        .onAppear(perform: count)
    }

    private var rating: PinDropScore.Rating { result.score.rating }

    private var header: some View {
        HStack(alignment: .center, spacing: DesignSystem.Spacing.sm) {
            Image(systemName: rating.systemImage)
                .font(DesignSystem.Font.title)
                .foregroundStyle(rating.color)
                .symbolEffect(.bounce, value: isCounted)
                .frame(width: 44)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
                Text(rating.title)
                    .font(DesignSystem.Font.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(result.round.country.name)
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer(minLength: DesignSystem.Spacing.sm)
            VStack(alignment: .trailing, spacing: 0) {
                CountingText(value: isCounted ? Double(result.score.total) : 0) { points in
                    "+" + PinDropStyle.points(points, locale: locale)
                }
                .font(DesignSystem.Font.title)
                .fontWeight(.heavy)
                .foregroundStyle(rating.color)
                Text("points")
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var chips: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            if result.isInside {
                chip(systemImage: "checkmark.seal.fill", color: DesignSystem.Color.success) {
                    Text("Inside")
                }
            } else {
                chip(systemImage: "ruler", color: DesignSystem.Color.textSecondary) {
                    CountingText(value: isCounted ? result.distanceKilometers : 0) { kilometers in
                        PinDropStyle.distance(kilometers, locale: locale)
                    }
                }
            }
            if result.score.speedBonus > 0 {
                chip(systemImage: "bolt.fill", color: DesignSystem.Color.warning) {
                    Text("Speed +\(result.score.speedBonus)")
                }
            }
            if result.score.streakMultiplier > 1 {
                chip(systemImage: "flame.fill", color: DesignSystem.Color.orange) {
                    Text(verbatim: "×" + result.score.streakMultiplier.formatted(.number.precision(.fractionLength(1))))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func chip(systemImage: String, color: Color, @ViewBuilder label: () -> some View) -> some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: systemImage)
                .foregroundStyle(color)
                .accessibilityHidden(true)
            label()
                .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .font(DesignSystem.Font.footnote)
        .fontWeight(.semibold)
        .lineLimit(1)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs + 2)
        .background(color.opacity(DesignSystem.Opacity.tint), in: .capsule)
    }

    private func count() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.9).delay(0.35)) {
            isCounted = true
        }
    }
}
