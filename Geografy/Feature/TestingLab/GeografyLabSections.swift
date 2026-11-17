#if DEBUG
import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI
import TestingLab

/// Geografy's own tools in the Testing Lab: the account, progress, achievements, streaks, the map cache, any
/// screen, switches, and resets.
struct GeografyLabSections: View {
    // MARK: - Properties
    @Environment(\.closeTestingLab) private var closeTestingLab
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
        accountSection
        progressSection
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
        achievementsSection
        streakSection
        mapSection
            .task { savedMapSize = geoJSONCache.savedMapSize }
        screensSection
        switchesSection
        resetSection
    }
}

// MARK: - Sections
private extension GeografyLabSections {
    var accountSection: some View {
        Section("Account") {
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
            LabeledContent {
                Text("\(xpService.currentLevel.level) · \(xpService.currentLevel.title)")
            } label: {
                LabRow("Level", systemImage: "rosette", color: DesignSystem.Color.purple)
            }
            LabeledContent {
                Text(xpService.totalXP.formatted())
            } label: {
                LabRow("Total XP", systemImage: "star.fill", color: DesignSystem.Color.warning)
            }
            Button { xpService.award(100, source: .dailyBonus) } label: {
                LabRow("Add 100 XP", systemImage: "plus", color: DesignSystem.Color.warning)
            }
            Button { xpService.award(1_000, source: .dailyBonus) } label: {
                LabRow("Add 1,000 XP", systemImage: "forward.fill", color: DesignSystem.Color.warning)
            }
            Button { closeTestingLab { data.reachNextLevel() } } label: {
                LabRow("Reach Next Level", systemImage: "arrow.up", color: DesignSystem.Color.purple)
            }
            .disabled(xpService.currentLevel.maxXP == Int.max)
            Button { closeTestingLab { xpService.levelUpPublisher.send(xpService.currentLevel) } } label: {
                LabRow("Show Level Up", systemImage: "sparkles", color: DesignSystem.Color.indigo)
            }
            Button(role: .destructive) { pendingReset = .xp } label: {
                LabRow("Reset XP", systemImage: "arrow.counterclockwise", isDestructive: true)
            }
        } header: {
            Text("Progress")
        } footer: {
            Text("Reaching a level and Show Level Up close the lab so the celebration is visible.")
        }
    }

    var achievementsSection: some View {
        Section("Achievements") {
            LabeledContent {
                Text("\(achievementService.unlockedCount) of \(AchievementCatalog.all.count)")
            } label: {
                LabRow("Unlocked", systemImage: "trophy.fill", color: DesignSystem.Color.warning)
            }
            Button { closeTestingLab { data.unlockNextAchievement() } } label: {
                LabRow("Unlock Next", systemImage: "lock.open.fill", color: DesignSystem.Color.warning)
            }
            Button {
                guard let sample = AchievementCatalog.all.randomElement() else { return }
                closeTestingLab { achievementService.unlockPublisher.send(sample) }
            } label: {
                LabRow(
                    "Show Unlock Banner",
                    systemImage: "rectangle.topthird.inset.filled",
                    color: DesignSystem.Color.blue
                )
            }
            Button(role: .destructive) { pendingReset = .achievements } label: {
                LabRow("Reset Achievements", systemImage: "arrow.counterclockwise", isDestructive: true)
            }
        }
    }

    var streakSection: some View {
        Section("Streak") {
            LabeledContent {
                Text("^[\(streakService.currentStreak) day](inflect: true)")
            } label: {
                LabRow("Current", systemImage: "flame.fill", color: DesignSystem.Color.orange)
            }
            LabeledContent {
                Text(streakService.hasPlayedToday ? "Yes" : "No")
            } label: {
                LabRow("Played Today", systemImage: "calendar", color: DesignSystem.Color.blue)
            }
            Menu {
                ForEach([1, 3, 7, 30, 100], id: \.self) { days in
                    Button("^[\(days) day](inflect: true)") { data.setStreak(days: days) }
                }
                Button("No streak", role: .destructive) { data.setStreak(days: 0) }
            } label: {
                LabRow("Set Streak", systemImage: "pencil", color: DesignSystem.Color.orange)
            }
        }
    }

    var mapSection: some View {
        Section("Map") {
            Picker(selection: $projection) {
                ForEach(MapProjectionKind.allCases) { kind in
                    Text(projectionName(kind)).tag(kind.rawValue)
                }
            } label: {
                LabRow("Projection", systemImage: "globe.europe.africa.fill", color: DesignSystem.Color.blue)
            }
            LabeledContent {
                Text(savedMapSize.formatted(.byteCount(style: .file)))
            } label: {
                LabRow("Saved Map", systemImage: "internaldrive.fill", color: DesignSystem.Color.textSecondary)
            }
            Button(role: .destructive) {
                geoJSONCache.clearSavedMap()
                savedMapSize = geoJSONCache.savedMapSize
            } label: {
                LabRow("Clear Saved Map", systemImage: "trash.fill", isDestructive: true)
            }
        }
    }

    var screensSection: some View {
        Section("Open a Screen") {
            DisclosureGroup {
                ForEach(HubItem.allCases.sorted { $0.label < $1.label }, id: \.self) { item in
                    Button { closeTestingLab { onOpen(item) } } label: {
                        LabRow(verbatim: item.label, systemImage: item.icon, color: item.color)
                    }
                }
            } label: {
                LabRow("All Screens", systemImage: "square.grid.2x2.fill", color: DesignSystem.Color.textSecondary)
            }
        }
    }

    var switchesSection: some View {
        Section {
            Toggle(isOn: Binding(get: { testingModeService.isEnabled }, set: { testingModeService.isEnabled = $0 })) {
                LabRow("Testing Mode", systemImage: "hammer.fill", color: DesignSystem.Color.orange)
            }
            .tint(DesignSystem.Color.accent)
        } header: {
            Text("Switches")
        } footer: {
            Text("Testing Mode adds a test checklist to each hub tile and a test sign-in.")
        }
    }

    var resetSection: some View {
        Section {
            Button(role: .destructive) { TestingLabData.resetGameSetups() } label: {
                LabRow("Reset Game Setups", systemImage: "slider.horizontal.3", isDestructive: true)
            }
            Button {
                closeTestingLab {
                    UserDefaults.standard.set(false, forKey: FirstRunScreen.completedKey)
                    UserDefaults.standard.set(true, forKey: FirstRunScreen.forcedKey)
                }
            } label: {
                LabRow("Show First Run", systemImage: "sparkles", color: DesignSystem.Color.blue)
            }
        } header: {
            Text("Reset")
        } footer: {
            Text("Game setups go back to each game's defaults. Show First Run replays the welcome, even with progress.")
        }
    }
}

// MARK: - Reset
private extension GeografyLabSections {
    enum Reset: Identifiable {
        case xp
        case achievements

        var id: Self { self }

        var title: String {
            switch self {
            case .xp: "Reset XP"
            case .achievements: "Reset Achievements"
            }
        }

        var message: String {
            switch self {
            case .xp: "Every XP record of this user is deleted, so the level goes back to 1."
            case .achievements: "Unlocked achievements, their progress, and pins are cleared."
            }
        }
    }

    func perform(_ reset: Reset) {
        switch reset {
        case .xp: data.resetXP()
        case .achievements: data.resetAchievements()
        }
    }
}

// MARK: - Helpers
private extension GeografyLabSections {
    var data: TestingLabData {
        TestingLabData(
            database: databaseManager,
            xpService: xpService,
            achievementService: achievementService,
            streakService: streakService
        )
    }

    func projectionName(_ kind: MapProjectionKind) -> String {
        switch kind {
        case .mercator: "Mercator"
        case .equalEarth: "Equal Earth"
        }
    }
}
#endif
