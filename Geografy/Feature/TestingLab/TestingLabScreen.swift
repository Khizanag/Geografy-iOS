#if DEBUG
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// Developer tools for trying the app in any state: progress, achievements, streaks, the map cache, any screen,
/// and a clean first launch. Opens on a shake or from Settings, in debug builds only.
struct TestingLabScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(AchievementService.self) private var achievementService
    @Environment(AuthService.self) private var authService
    @Environment(DatabaseManager.self) private var databaseManager
    @Environment(GeoJSONCache.self) private var geoJSONCache
    @Environment(StreakService.self) private var streakService
    @Environment(TestingModeService.self) private var testingModeService
    @Environment(XPService.self) private var xpService

    @AppStorage(MapPreferences.projectionKey) private var projection = MapProjectionKind.mercator.rawValue

    @State private var savedMapSize = 0
    @State private var pendingReset: Reset?

    let onOpen: (HubItem) -> Void

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                buildSection
                progressSection
                achievementsSection
                streakSection
                mapSection
                screensSection
                switchesSection
                resetSection
            }
            .navigationTitle("Testing Lab")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", systemImage: "checkmark") { dismiss() }
                }
            }
            .confirmationDialog(
                pendingReset?.title ?? "",
                isPresented: Binding(get: { pendingReset != nil }, set: { if !$0 { pendingReset = nil } }),
                titleVisibility: .visible,
                presenting: pendingReset
            ) { reset in
                Button(reset.title, role: .destructive) { perform(reset) }
                Button("Cancel", role: .cancel) {}
            } message: { reset in
                Text(reset.message)
            }
        }
        .tint(DesignSystem.Color.accent)
        .task { savedMapSize = geoJSONCache.savedMapSize }
    }
}

// MARK: - Sections
private extension TestingLabScreen {
    var buildSection: some View {
        Section("Build") {
            LabeledContent("Version", value: version)
            LabeledContent("Bundle ID", value: Bundle.main.bundleIdentifier ?? "–")
            LabeledContent("User", value: authService.isGuest ? "Guest" : "Signed in")
            LabeledContent("User ID") {
                Text(authService.currentUserID)
                    .font(DesignSystem.Font.caption.monospaced())
                    .textSelection(.enabled)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            if databaseManager.isUsingFallbackStore {
                Label(
                    "The store failed to open, so data lives in memory only.",
                    systemImage: "exclamationmark.triangle.fill"
                )
                .foregroundStyle(DesignSystem.Color.warning)
            }
        }
    }

    var progressSection: some View {
        Section {
            LabeledContent("Level", value: "\(xpService.currentLevel.level) · \(xpService.currentLevel.title)")
            LabeledContent("Total XP", value: xpService.totalXP.formatted())
            Button("Add 100 XP", systemImage: "plus.circle") { xpService.award(100, source: .dailyLogin) }
            Button("Add 1,000 XP", systemImage: "plus.circle.fill") { xpService.award(1_000, source: .dailyLogin) }
            Button("Reach Next Level", systemImage: "arrow.up.circle") { closeThen { data.reachNextLevel() } }
                .disabled(xpService.currentLevel.maxXP == Int.max)
            Button("Show Level Up", systemImage: "sparkles") {
                closeThen { xpService.levelUpPublisher.send(xpService.currentLevel) }
            }
            Button("Reset XP", systemImage: "arrow.counterclockwise", role: .destructive) { pendingReset = .xp }
        } header: {
            Text("Progress")
        } footer: {
            Text("Reaching a level and Show Level Up close the lab so the celebration is visible.")
        }
    }

    var achievementsSection: some View {
        Section("Achievements") {
            LabeledContent(
                "Unlocked",
                value: "\(achievementService.unlockedAchievements.count) of \(AchievementCatalog.all.count)"
            )
            Button("Unlock Next", systemImage: "trophy") { closeThen { data.unlockNextAchievement() } }
            Button("Show Unlock Banner", systemImage: "rectangle.topthird.inset.filled") {
                guard let sample = AchievementCatalog.all.randomElement() else { return }
                closeThen { achievementService.unlockPublisher.send(sample) }
            }
            Button("Reset Achievements", systemImage: "arrow.counterclockwise", role: .destructive) {
                pendingReset = .achievements
            }
        }
    }

    var streakSection: some View {
        Section("Streak") {
            LabeledContent("Current") {
                Text("^[\(streakService.currentStreak) day](inflect: true)")
            }
            LabeledContent("Played Today", value: streakService.hasPlayedToday ? "Yes" : "No")
            Menu {
                ForEach([1, 3, 7, 30, 100], id: \.self) { days in
                    Button("^[\(days) day](inflect: true)") { data.setStreak(days: days) }
                }
                Button("No streak", role: .destructive) { data.setStreak(days: 0) }
            } label: {
                Label("Set Streak", systemImage: "flame")
            }
        }
    }

    var mapSection: some View {
        Section("Map") {
            Picker("Projection", selection: $projection) {
                ForEach(MapProjectionKind.allCases) { kind in
                    Text(projectionName(kind)).tag(kind.rawValue)
                }
            }
            LabeledContent("Saved Map", value: savedMapSize.formatted(.byteCount(style: .file)))
            Button("Clear Saved Map", systemImage: "trash") {
                geoJSONCache.clearSavedMap()
                savedMapSize = geoJSONCache.savedMapSize
            }
        }
    }

    var screensSection: some View {
        Section("Open a Screen") {
            DisclosureGroup("All Screens") {
                ForEach(HubItem.allCases.sorted { $0.label < $1.label }, id: \.self) { item in
                    Button {
                        closeThen { onOpen(item) }
                    } label: {
                        Label(item.label, systemImage: item.icon)
                    }
                }
            }
        }
    }

    var switchesSection: some View {
        Section {
            Toggle(
                "Testing Mode",
                isOn: Binding(get: { testingModeService.isEnabled }, set: { testingModeService.isEnabled = $0 })
            )
        } header: {
            Text("Switches")
        } footer: {
            Text("Testing Mode adds a test checklist to each hub tile and a test sign-in.")
        }
    }

    var resetSection: some View {
        Section {
            Button("Reset Game Setups", systemImage: "slider.horizontal.3") { TestingLabData.resetGameSetups() }
            Button("Erase Everything and Quit", systemImage: "exclamationmark.octagon", role: .destructive) {
                pendingReset = .everything
            }
        } header: {
            Text("Reset")
        } footer: {
            Text(
                "Game setups go back to each game's defaults. Erasing deletes all progress, settings, and caches, "
                    + "then quits; open the app again for a first launch."
            )
        }
    }
}

// MARK: - Reset
private extension TestingLabScreen {
    enum Reset: Identifiable {
        case xp
        case achievements
        case everything

        var id: Self { self }

        var title: String {
            switch self {
            case .xp: "Reset XP"
            case .achievements: "Reset Achievements"
            case .everything: "Erase Everything and Quit"
            }
        }

        var message: String {
            switch self {
            case .xp: "Every XP record of this user is deleted, so the level goes back to 1."
            case .achievements: "Unlocked achievements, their progress, and pins are cleared."
            case .everything: "All progress, settings, and caches are deleted and the app quits."
            }
        }
    }

    func perform(_ reset: Reset) {
        switch reset {
        case .xp: data.resetXP()
        case .achievements: data.resetAchievements()
        case .everything: data.eraseEverythingAndQuit()
        }
    }
}

// MARK: - Helpers
private extension TestingLabScreen {
    var data: TestingLabData {
        TestingLabData(
            database: databaseManager,
            xpService: xpService,
            achievementService: achievementService,
            streakService: streakService
        )
    }

    /// Closes the lab first, so what the action shows over the app isn't hidden behind it.
    func closeThen(_ action: @escaping @MainActor () -> Void) {
        dismiss()
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            action()
        }
    }

    var version: String {
        let info = Bundle.main.infoDictionary
        let short = info?["CFBundleShortVersionString"] as? String ?? "–"
        let build = info?["CFBundleVersion"] as? String ?? "–"
        return "\(short) (\(build))"
    }

    func projectionName(_ kind: MapProjectionKind) -> String {
        switch kind {
        case .mercator: "Mercator"
        case .equalEarth: "Equal Earth"
        }
    }
}
#endif
