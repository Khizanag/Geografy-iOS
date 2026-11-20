import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// What a new player sees once: a welcome, their home country, and an optional daily reminder, ending on
/// today's Daily Challenge.
struct FirstRunScreen: View {
    // MARK: - Properties
    static let completedKey = "hasCompletedFirstRun"
    /// Set by the Testing Lab, so the first run shows even for a player who has progress.
    static let forcedKey = "firstRunForced"
    /// The country the player calls home, marked visited and kept for features that start from it.
    static let homeCountryKey = "homeCountryCode"

    @Environment(CountryDataService.self) private var countryDataService
    @Environment(TravelService.self) private var travelService
    @Environment(StreakService.self) private var streakService
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @AppStorage(FirstRunScreen.completedKey) private var hasCompleted = false
    @AppStorage(NotificationService.preferenceKey) private var remindersEnabled = false

    @State private var step = Step.welcome
    @State private var homeCountry: Country?
    @State private var isPickingCountry = false

    // MARK: - Body
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer(minLength: 0)
            content
                .id(step)
                .transition(reduceMotion ? .opacity : .push(from: .trailing))
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.lg)
        .readableContentWidth()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .safeAreaBar(edge: .bottom) {
            actions
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.md)
        }
        .sheet(isPresented: $isPickingCountry) {
            NavigationStack {
                CountryPicker("Your Home Country", countries: countryDataService.countries) { country in
                    homeCountry = country
                    isPickingCountry = false
                }
            }
        }
    }
}

// MARK: - Steps
private extension FirstRunScreen {
    enum Step {
        case welcome
        case home
        case reminders
    }

    @ViewBuilder
    var content: some View {
        switch step {
        case .welcome:
            page(
                icon: "globe.europe.africa.fill",
                color: DesignSystem.Color.blue,
                title: "Welcome to Geografy",
                message: "Learn every country's flag, capital, and place on the map, a few minutes a day."
            )
        case .home:
            VStack(spacing: DesignSystem.Spacing.lg) {
                page(
                    icon: "house.fill",
                    color: DesignSystem.Color.teal,
                    title: "Where's Home?",
                    message: "We'll mark it as your first visited country."
                )
                homeCountryButton
            }
        case .reminders:
            page(
                icon: "bell.badge.fill",
                color: DesignSystem.Color.orange,
                title: "A Daily Nudge",
                message: "One for the Daily Challenge, and one in the evening if your streak is about to end."
            )
        }
    }

    func page(icon: String, color: Color, title: LocalizedStringKey, message: LocalizedStringKey) -> some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            IconBadge(icon, color: color, size: .hero)
            Text(title)
                .font(DesignSystem.Font.title)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Text(message)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    var homeCountryButton: some View {
        Button { isPickingCountry = true } label: {
            CardView {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    if let homeCountry {
                        FlagView(countryCode: homeCountry.code, height: DesignSystem.Size.Flag.row)
                            .accessibilityHidden(true)
                        Text(homeCountry.name)
                            .font(DesignSystem.Font.headline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                            .accessibilityHidden(true)
                        Text("Choose Your Country")
                            .font(DesignSystem.Font.headline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                    }
                    Spacer()
                    RowChevron()
                }
                .rowListCardRow()
            }
        }
        .buttonStyle(PressButtonStyle())
        .disabled(countryDataService.countries.isEmpty)
    }
}

// MARK: - Actions
private extension FirstRunScreen {
    @ViewBuilder
    var actions: some View {
        switch step {
        case .welcome:
            GlassButton("Get Started", fullWidth: true) { advance(to: .home) }
        case .home:
            ButtonRow {
                GlassButton("Skip", role: .secondary, fullWidth: true) { advance(to: .reminders) }
                GlassButton("Continue", fullWidth: true) { advance(to: .reminders) }
                    .disabled(homeCountry == nil)
            }
        case .reminders:
            ButtonRow {
                GlassButton("Not Now", role: .secondary, fullWidth: true) { finish() }
                GlassButton("Remind Me", systemImage: "bell.fill", fullWidth: true) {
                    Task { await enableReminders() }
                }
            }
        }
    }

    func advance(to next: Step) {
        withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .smooth(duration: 0.35)) {
            step = next
        }
    }

    func enableReminders() async {
        #if os(iOS)
        remindersEnabled = await NotificationService.requestPermission()
        await NotificationService.syncReminders(enabled: remindersEnabled, learnedToday: streakService.hasPlayedToday)
        #endif
        finish()
    }

    /// Marks home as visited and opens today's challenge, so the first thing after the welcome is playing.
    func finish() {
        if let homeCountry {
            travelService.set(status: .visited, for: homeCountry.code)
            UserDefaults.standard.set(homeCountry.code, forKey: Self.homeCountryKey)
        }
        hasCompleted = true
        UserDefaults.standard.removeObject(forKey: Self.forcedKey)
        AppRequests.shared.send(.firstRunFinished(homeCountryCode: homeCountry?.code))
    }
}
