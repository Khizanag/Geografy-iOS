import SwiftUI

struct FlagGameResultScreen: View {
    let score: Int
    let answeredCountries: [Country]
    let onPlayAgain: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()
            headerSection
            scoreSection
            countriesLearnedSection
            Spacer()
            actionButtons
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.xl)
    }
}

// MARK: - Subviews
private extension FlagGameResultScreen {
    var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Color.orange.opacity(0.15))
                    .frame(width: 80, height: 80)
                Image(systemName: "flag.fill")
                    .font(DesignSystem.Font.iconXL)
                    .foregroundStyle(DesignSystem.Color.orange)
            }
            Text("Round Complete!")
                .font(DesignSystem.Font.title2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Text(performanceMessage)
                .font(DesignSystem.Font.subheadline)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    var performanceMessage: String {
        switch score {
        case 0..<30: "Keep practicing — you'll get there!"
        case 30..<60: "Good effort! Try to beat your score."
        case 60..<100: "Great work! You know your flags well."
        default: "Amazing! You're a flag master!"
        }
    }

    var scoreSection: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.xl) {
                ResultStatItem(
                    icon: "star.fill",
                    value: "\(score)",
                    label: "Score",
                    color: DesignSystem.Color.orange
                )
                Divider().frame(height: 40)
                ResultStatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(answeredCountries.count)",
                    label: "Correct",
                    color: DesignSystem.Color.success
                )
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }

    @ViewBuilder
    var countriesLearnedSection: some View {
        if !answeredCountries.isEmpty {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Countries You Got Right")
                    .font(DesignSystem.Font.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(answeredCountries) { country in
                            countrySummaryChip(country)
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .readableContentWidth()
                }
                .scrollClipDisabled()
            }
        }
    }

    func countrySummaryChip(_ country: Country) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.xs) {
                FlagView(countryCode: country.code, height: 32)
                Text(country.name)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .padding(DesignSystem.Spacing.sm)
            .frame(width: 80)
        }
    }

    var actionButtons: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Button(action: onPlayAgain) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "arrow.clockwise")
                    Text("Play Again")
                        .fontWeight(.bold)
                }
                .font(DesignSystem.Font.headline)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md)
            }
            .buttonStyle(.glass)

            Button(action: onDismiss) {
                Text("Done")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
            .buttonStyle(.plain)
        }
    }
}
