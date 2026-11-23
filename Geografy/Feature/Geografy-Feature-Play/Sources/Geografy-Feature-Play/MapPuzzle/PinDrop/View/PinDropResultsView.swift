import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// The end of a game: a grade, the score counting up, the record, and every round's pin.
struct PinDropResultsView: View {
    // MARK: - Properties
    @Environment(\.locale) private var locale
    @Environment(AchievementService.self) private var achievementService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let results: [PinDropGame.Result]
    let roundCount: Int
    let bestScore: Int
    let isNewBest: Bool
    let onDone: () -> Void
    let onPlayAgain: () -> Void

    @State private var isRevealed = false

    // MARK: - Body
    var body: some View {
        GameResultLayout(
            title: Text(grade.message),
            xpEarned: PinDropScoring.xp(for: results),
            primaryAction: .playAgain(onPlayAgain),
            share: resultShare,
            sound: isNewBest ? .celebrate : .complete,
            onDone: onDone,
            hero: {
                VStack(spacing: DesignSystem.Spacing.md) {
                    gradeBadge
                    scoreBlock
                }
            },
            stats: { stats },
            details: { roundList }
        )
        // Solid, so the glass buttons inside aren't glass on glass.
        .background(
            DesignSystem.Color.background,
            in: .rect(cornerRadius: DesignSystem.CornerRadius.extraLarge)
        )
        .onAppear(perform: reveal)
    }
}

// MARK: - Subviews
private extension PinDropResultsView {
    var totalScore: Int { results.reduce(0) { $0 + $1.score.total } }

    var resultShare: ResultShare {
        ResultShare(
            game: String(localized: "Pin Drop"),
            score: totalScore.formatted(),
            caption: String(localized: "\(results.count { $0.isInside }) of \(roundCount) bullseyes"),
            details: [
                ResultShare.Detail(
                    String(localized: "\(PinDropStyle.distance(averageMiss, locale: locale)) average miss"),
                    systemImage: "scope"
                ),
            ],
            onShare: achievementService.recordShare
        )
    }

    var grade: PinDropGrade { PinDropScoring.grade(totalPoints: totalScore, roundCount: roundCount) }

    var gradeBadge: some View {
        ZStack {
            Circle()
                .strokeBorder(
                    grade.color.opacity(DesignSystem.Opacity.half),
                    style: StrokeStyle(lineWidth: 3, dash: [4, 7])
                )
                .frame(width: 132, height: 132)
                .rotationEffect(.degrees(isRevealed && !reduceMotion ? 360 : 0))
                .animation(
                    reduceMotion ? nil : .linear(duration: 14).repeatForever(autoreverses: false),
                    value: isRevealed
                )
            Circle()
                .fill(grade.color.gradient)
                .frame(width: 108, height: 108)
                .shadow(color: grade.color.opacity(DesignSystem.Opacity.half), radius: 16, y: 6)
            Text(verbatim: grade.rawValue)
                .font(DesignSystem.Font.roundedHero)
                .foregroundStyle(DesignSystem.Color.onAccent)
        }
        .scaleEffect(isRevealed ? 1 : 0.3)
        .opacity(isRevealed ? 1 : 0)
        .animation(reduceMotion ? nil : .spring(duration: 0.6, bounce: 0.45), value: isRevealed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Grade \(grade.rawValue)"))
    }

    var scoreBlock: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            CountingText(value: isRevealed ? Double(totalScore) : 0) { points in
                PinDropStyle.points(points, locale: locale)
            }
            .font(DesignSystem.Font.roundedXL)
            .foregroundStyle(DesignSystem.Color.textPrimary)
            recordLabel
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    var recordLabel: some View {
        if isNewBest {
            Label("New Best", systemImage: "trophy.fill")
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.warning)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xxs)
                .background(DesignSystem.Color.warning.opacity(DesignSystem.Opacity.tint), in: .capsule)
                .symbolEffect(.bounce, value: isRevealed)
        } else if bestScore > 0 {
            Text("Best: \(PinDropStyle.points(Double(bestScore), locale: locale))")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textSecondary)
        }
    }

    @ViewBuilder
    var stats: some View {
        StatTile(
            value: "\(results.count { $0.isInside })/\(roundCount)",
            label: "Bullseyes",
            icon: "scope",
            color: DesignSystem.Color.success
        )
        StatTile(
            value: PinDropStyle.distance(averageMiss, locale: locale),
            label: "Average Miss",
            icon: "ruler",
            color: DesignSystem.Color.blue
        )
        StatTile(
            value: "\(results.map(\.score.streak).max() ?? 0)",
            label: "Best Streak",
            icon: "flame.fill",
            color: DesignSystem.Color.orange
        )
    }

    var averageMiss: Double {
        guard !results.isEmpty else { return 0 }
        return results.reduce(0) { $0 + $1.distanceKilometers } / Double(results.count)
    }

    var roundList: some View {
        VStack(spacing: 0) {
            ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                if index > 0 {
                    Divider().padding(.leading, DesignSystem.Spacing.xxl)
                }
                roundRow(result)
            }
        }
    }

    func roundRow(_ result: PinDropGame.Result) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            FlagView(countryCode: result.round.id, height: 18, isOutlined: true)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
                Text(result.round.country.name)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)
                (result.isInside ? Text("Inside") : Text(verbatim: missText(result)))
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            Spacer(minLength: DesignSystem.Spacing.xs)
            Image(systemName: result.score.rating.systemImage)
                .foregroundStyle(result.score.rating.color)
                .accessibilityHidden(true)
            Text(verbatim: PinDropStyle.points(Double(result.score.total), locale: locale))
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .frame(minWidth: 52, alignment: .trailing)
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
        .accessibilityElement(children: .combine)
    }

    func missText(_ result: PinDropGame.Result) -> String {
        PinDropStyle.distance(result.distanceKilometers, locale: locale)
    }

    func reveal() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 1.2).delay(0.2)) {
            isRevealed = true
        }
        let announcement = "Grade \(grade.rawValue). \(totalScore) points."
        AccessibilityNotification.Announcement(announcement).post()
    }
}
