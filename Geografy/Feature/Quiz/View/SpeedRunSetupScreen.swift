import SwiftUI
import GeografyDesign

struct SpeedRunSetupScreen: View {
    @Environment(Navigator.self) private var coordinator
    @Environment(HapticsService.self) private var hapticsService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @AppStorage("speedrun_selectedRegion") private var selectedRegion: QuizRegion = .world

    @State private var appeared = false
    @State private var pulseTimer = false
    @State private var countryDataService = CountryDataService()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                heroSection

                bestTimeCard

                regionSection

                challengeStatsGrid

                rulesSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.md)
            .readableContentWidth()
        }
        .safeAreaInset(edge: .bottom) { startButton }
        .background { AmbientBlobsView(.quiz) }
        .background(DesignSystem.Color.background.ignoresSafeArea())
        .navigationTitle("Speed Run")
        .navigationBarTitleDisplayMode(.inline)
        .task { countryDataService.loadCountries() }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) { appeared = true }
            guard !reduceMotion else { pulseTimer = true; return }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseTimer = true
            }
        }
    }
}

// MARK: - Hero
private extension SpeedRunSetupScreen {
    var heroSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            timerIcon

            VStack(spacing: DesignSystem.Spacing.xs) {
                Text("Speed Run")
                    .font(DesignSystem.Font.roundedTitle2)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Text("Name every country.\nAs fast as you can.")
                    .font(DesignSystem.Font.subheadline)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }

            countryCountBadge
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    var timerIcon: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Color.error.opacity(0.25),
                            DesignSystem.Color.error.opacity(0.0),
                        ],
                        center: .center,
                        startRadius: 8,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(pulseTimer ? 1.08 : 0.92)

            Circle()
                .fill(DesignSystem.Color.error.opacity(0.12))
                .frame(width: 80, height: 80)

            Image(systemName: "timer")
                .font(DesignSystem.Font.iconXL.weight(.semibold))
                .foregroundStyle(DesignSystem.Color.error)
                .symbolEffect(.pulse, options: .repeating, value: appeared)
        }
    }

    var countryCountBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "flag.fill")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.error)
            Text("\(countryCount) countries to name")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.error)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs + 2)
        .background(DesignSystem.Color.error.opacity(0.12), in: Capsule())
        .contentTransition(.numericText())
        .animation(.easeInOut(duration: 0.3), value: selectedRegion)
    }
}

// MARK: - Best Time
private extension SpeedRunSetupScreen {
    var bestTimeCard: some View {
        CardView {
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Color.warning.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "trophy.fill")
                        .font(DesignSystem.Font.iconSmall)
                        .foregroundStyle(DesignSystem.Color.warning)
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Personal Best")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                    Text(personalBestText)
                        .font(DesignSystem.Font.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: DesignSystem.Spacing.xxs) {
                    Text("Leaderboard")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
            }
            .padding(DesignSystem.Spacing.md)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.easeOut(duration: 0.6).delay(0.15), value: appeared)
    }
}

// MARK: - Region Carousel
private extension SpeedRunSetupScreen {
    var regionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("Choose Region")
                .padding(.horizontal, DesignSystem.Spacing.md)

            RegionCarousel(selectedRegion: $selectedRegion)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.easeOut(duration: 0.6).delay(0.25), value: appeared)
    }

}

// MARK: - Challenge Stats
private extension SpeedRunSetupScreen {
    var challengeStatsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: DesignSystem.Spacing.sm
        ) {
            statTile(
                icon: "bolt.fill",
                value: "Typing",
                label: "Answer Mode",
                color: DesignSystem.Color.warning
            )
            statTile(
                icon: "infinity",
                value: "No Limit",
                label: "Time",
                color: DesignSystem.Color.blue
            )
            statTile(
                icon: "star.fill",
                value: "+50 XP",
                label: "Completion",
                color: DesignSystem.Color.accent
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.easeOut(duration: 0.6).delay(0.35), value: appeared)
    }

    func statTile(icon: String, value: String, label: String, color: Color) -> some View {
        CardView {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(DesignSystem.Font.callout.weight(.semibold))
                    .foregroundStyle(color)
                Text(value)
                    .font(DesignSystem.Font.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(label)
                    .font(DesignSystem.Font.caption2)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .padding(.horizontal, DesignSystem.Spacing.xs)
        }
    }
}

// MARK: - Rules
private extension SpeedRunSetupScreen {
    var rulesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            sectionTitle("How It Works")
            CardView {
                VStack(spacing: 0) {
                    ruleRow(
                        step: "1",
                        icon: "keyboard",
                        color: DesignSystem.Color.blue,
                        title: "Type & Submit",
                        subtitle: "Type country names one by one"
                    )
                    ruleDivider
                    ruleRow(
                        step: "2",
                        icon: "checkmark.circle.fill",
                        color: DesignSystem.Color.success,
                        title: "Instant Feedback",
                        subtitle: "Correct answers flash green"
                    )
                    ruleDivider
                    ruleRow(
                        step: "3",
                        icon: "timer",
                        color: DesignSystem.Color.error,
                        title: "Race the Clock",
                        subtitle: "Finish faster for more XP"
                    )
                    ruleDivider
                    ruleRow(
                        step: "4",
                        icon: "trophy.fill",
                        color: DesignSystem.Color.warning,
                        title: "Compete",
                        subtitle: "Best times go to Game Center"
                    )
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.easeOut(duration: 0.6).delay(0.45), value: appeared)
    }

    var ruleDivider: some View {
        Divider()
            .padding(.leading, 56)
    }

    func ruleRow(
        step: String,
        icon: String,
        color: Color,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(DesignSystem.Font.subheadline.weight(.medium))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Font.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text(subtitle)
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

// MARK: - Start Button
private extension SpeedRunSetupScreen {
    var startButton: some View {
        GlassButton("Start Speed Run", systemImage: "bolt.fill", fullWidth: true) {
            hapticsService.impact(.medium)
            coordinator.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                coordinator.cover(
                    .speedRunSession(region: selectedRegion)
                )
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Helpers
private extension SpeedRunSetupScreen {
    func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(DesignSystem.Font.headline)
            .fontWeight(.semibold)
            .foregroundStyle(DesignSystem.Color.textPrimary)
    }

    var countryCount: Int {
        selectedRegion.filter(countryDataService.countries).count
    }

    var personalBestText: String {
        let key = "speedrun_best_\(selectedRegion.rawValue)"
        let best = UserDefaults.standard.double(forKey: key)
        if best > 0 {
            let minutes = Int(best) / 60
            let seconds = Int(best) % 60
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
        return "—"
    }

}
