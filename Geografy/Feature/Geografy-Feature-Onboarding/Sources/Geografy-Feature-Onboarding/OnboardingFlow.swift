import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

/// Four-step first-run flow.
///
/// 1. Hero — brand promise + Lottie globe (with SF fallback).
/// 2. Continent — pick the user's favourite continent (drives Home sort).
/// 3. Goal — Casual / Learner / Traveller / Completionist (shapes XP targets).
/// 4. Permissions — local notifications for streak reminders.
///
/// The last step's "Get started" button calls `onComplete()` and flips
/// `@AppStorage("didCompleteOnboarding")` to `true` so the flow never runs
/// again — except when the developer menu resets it.
public struct OnboardingFlow: View {
    public enum Goal: String, CaseIterable, Identifiable, Sendable {
        case casual
        case learner
        case traveller
        case completionist

        public var id: String { rawValue }

        public var title: String {
            switch self {
            case .casual:        "Casual"
            case .learner:       "Learner"
            case .traveller:     "Traveller"
            case .completionist: "Completionist"
            }
        }

        public var subtitle: String {
            switch self {
            case .casual:        "A few minutes a day"
            case .learner:       "Ten minutes, every day"
            case .traveller:     "Facts and phrases for trips"
            case .completionist: "Master every country"
            }
        }

        public var icon: String {
            switch self {
            case .casual:        "leaf"
            case .learner:       "book.closed"
            case .traveller:     "airplane"
            case .completionist: "crown"
            }
        }
    }

    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false
    @AppStorage("onboarding.favouriteContinent") private var favouriteContinentRaw = ""
    @AppStorage("onboarding.goal") private var goalRaw = Goal.casual.rawValue
    @AppStorage("onboarding.notificationsOptIn") private var notificationsOptIn = false

    @State private var step = 0

    private let onComplete: () -> Void

    public init(onComplete: @escaping () -> Void = {}) {
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            MetalAmbientView(preset: .hero)
                .ignoresSafeArea()

            VStack {
                steps

                Spacer()

                controls
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
}

// MARK: - Steps
private extension OnboardingFlow {
    @ViewBuilder
    var steps: some View {
        switch step {
        case 0: heroStep
        case 1: continentStep
        case 2: goalStep
        default: permissionsStep
        }
    }

    var heroStep: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            GeoLottieView(.emptyStateGlobe, loopMode: .loop) {
                Image(systemName: "globe.europe.africa.fill")
                    .font(DesignSystem.Font.displayXS)
                    .foregroundStyle(DesignSystem.Color.onAccent)
            }
            .frame(width: 200, height: 200)

            Text("Learn the world, one flag at a time.")
                .font(DesignSystem.Font.roundedHero)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)

            Text("Quizzes, maps, and stories for every country.")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .phaseEntrance(index: 0)
    }

    var continentStep: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Where are you from?")
                .font(DesignSystem.Font.roundedTitle)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("We'll put your region first on the home feed.")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)

            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: DesignSystem.Spacing.sm) {
                ForEach(Country.Continent.allCases, id: \.self) { continent in
                    continentChip(continent)
                }
            }
        }
    }

    var goalStep: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Pick a goal")
                .font(DesignSystem.Font.roundedTitle)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(Goal.allCases) { goal in
                    goalRow(goal)
                }
            }
        }
    }

    var permissionsStep: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "bell.badge")
                .font(DesignSystem.Font.displayXS)
                .foregroundStyle(DesignSystem.Color.accent)

            Text("Stay on your streak")
                .font(DesignSystem.Font.roundedTitle)
                .foregroundStyle(DesignSystem.Color.textPrimary)

            Text("A daily nudge keeps your streak alive. You can change this in Settings at any time.")
                .font(DesignSystem.Font.callout)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)

            Toggle("Daily reminders", isOn: $notificationsOptIn)
                .toggleStyle(.switch)
                .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
}

// MARK: - Components
private extension OnboardingFlow {
    func continentChip(_ continent: Country.Continent) -> some View {
        let isSelected = favouriteContinentRaw == continent.rawValue
        return Button {
            favouriteContinentRaw = continent.rawValue
        } label: {
            VStack(spacing: 6) {
                Image(systemName: continent.icon)
                    .font(DesignSystem.Font.iconLarge)
                Text(continent.displayName)
                    .font(DesignSystem.Font.callout)
            }
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                    .fill(isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    func goalRow(_ goal: Goal) -> some View {
        let isSelected = goalRaw == goal.rawValue
        return Button {
            goalRaw = goal.rawValue
        } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: goal.icon)
                    .font(DesignSystem.Font.iconLarge)
                    .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.accent)
                    .frame(width: DesignSystem.Size.Avatar.md)

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(DesignSystem.Font.headline)
                    Text(goal.subtitle)
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(
                            isSelected
                                ? DesignSystem.Color.onAccent.opacity(0.8)
                                : DesignSystem.Color.textSecondary
                        )
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(DesignSystem.Color.onAccent)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                    .fill(isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    var controls: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if step > 0 {
                Button("Back") {
                    withAnimation { step -= 1 }
                }
                .buttonStyle(.plain)
                .foregroundStyle(DesignSystem.Color.textSecondary)
            }

            Spacer()

            Button(action: advance) {
                Text(step < 3 ? "Continue" : "Get started")
                    .font(DesignSystem.Font.headline)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.vertical, DesignSystem.Spacing.sm)
            }
            .buttonStyle(.borderedProminent)
            .tint(DesignSystem.Color.accent)
        }
    }
}

// MARK: - Actions
private extension OnboardingFlow {
    func advance() {
        if step >= 3 {
            didCompleteOnboarding = true
            onComplete()
        } else {
            withAnimation { step += 1 }
        }
    }
}
