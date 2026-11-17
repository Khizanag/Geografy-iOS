import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import StoreKit
import SwiftUI
#if DEBUG
import TestingLab
#endif

public struct SettingsScreen: View {
    // MARK: - Properties
    @Environment(AuthService.self) private var authService
    @Environment(LanguageService.self) private var languageService
    @Environment(Navigator.self) private var coordinator
    @Environment(\.openURL) private var openURL
    @Environment(\.locale) private var locale
    @Environment(\.scenePhase) private var scenePhase
    #if DEBUG
    @Environment(\.openTestingLab) private var openTestingLab
    #endif
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif

    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage(MapPreferences.showsGraticuleKey) private var showsGraticule = false
    @AppStorage(MapPreferences.projectionKey) private var projection = MapProjectionKind.mercator.rawValue
    @AppStorage("pronunciationEnabled") private var pronunciationEnabled = true
    @AppStorage("selectedTheme") private var selectedTheme = "Auto"

    @State private var showDeleteConfirmation = false
    @State private var showSignOutConfirmation = false

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .screenBackground()
            // Built from the locale, so the title follows a language switch made on this screen;
            // a bar keeps a plain key's first translation.
            .navigationTitle(String(localized: "Settings", in: locale))
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .confirmationDialog(
                "Delete Account",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Account", role: .destructive) {
                    authService.deleteAccount()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All your progress, XP, and achievements will be permanently deleted.")
            }
            .confirmationDialog(
                "Sign Out",
                isPresented: $showSignOutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Sign Out", role: .destructive) {
                    authService.signOut()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You can sign back in anytime to restore your progress.")
            }
    }
}

// MARK: - Content
private extension SettingsScreen {
    var scrollContent: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                accountSection
                preferencesSection
                mapSection
                languageSection
                soundAndHapticsSection
                notificationsSection
                aboutSection
                #if DEBUG
                developerSection
                #endif
                versionFooter
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .readableContentWidth()
        }
    }
}

// MARK: - Account
private extension SettingsScreen {
    var accountSection: some View {
        settingsGroup(header: "Account") {
            if !authService.isGuest {
                authenticatedRows
            } else {
                guestRows
            }
        }
    }

    var authenticatedRows: some View {
        VStack(spacing: 0) {
            profileRow
            settingsDivider
            signOutRow
            settingsDivider
            deleteAccountRow
        }
    }

    var guestRows: some View {
        VStack(spacing: 0) {
            guestProfileRow

            settingsDivider

            signInRow
        }
    }

    var profileRow: some View {
        Button { coordinator.sheet(ProfileRoute.profile) } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ProfileAvatarView(
                    name: authService.currentProfile?.displayName ?? "Explorer",
                    size: DesignSystem.Size.md
                )
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
                    Text(authService.currentProfile?.displayName ?? "Explorer")
                        .font(DesignSystem.Font.body)
                        .fontWeight(.medium)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(authService.currentProfile?.email ?? "View profile")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                Spacer()
                RowChevron()
            }
            .settingsRowPadding()
        }
        .buttonStyle(PressButtonStyle())
    }

    var guestProfileRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: "person.fill", color: DesignSystem.Color.textSecondary)
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
                Text("Guest")
                    .font(DesignSystem.Font.body)
                    .fontWeight(.medium)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Text("Progress saved on this device only")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            Spacer()
        }
        .settingsRowPadding()
    }

    var signInRow: some View {
        Button { coordinator.push(ProfileLocalRoute.signIn) } label: {
            SettingsNavigationRow(
                icon: "person.badge.plus",
                iconColor: DesignSystem.Color.blue,
                title: "Sign In"
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var signOutRow: some View {
        Button { showSignOutConfirmation = true } label: {
            SettingsActionRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", isDestructive: true)
        }
        .buttonStyle(PressButtonStyle())
    }

    var deleteAccountRow: some View {
        Button { showDeleteConfirmation = true } label: {
            SettingsActionRow(icon: "trash.fill", title: "Delete Account", isDestructive: true)
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Map
private extension SettingsScreen {
    var mapSection: some View {
        settingsGroup(header: "Map") {
            VStack(spacing: 0) {
                projectionRow

                settingsDivider

                Button { coordinator.push(MapRoute.mapColors) } label: {
                    SettingsNavigationRow(
                        icon: "paintpalette.fill",
                        iconColor: DesignSystem.Color.orange,
                        title: "Map colors"
                    )
                }
                .buttonStyle(PressButtonStyle())

                settingsDivider

                SettingsToggleRow(
                    icon: "globe",
                    iconColor: DesignSystem.Color.blue,
                    title: "Latitude & longitude on maps",
                    isOn: $showsGraticule.animation()
                )
            }
        }
    }
}

// MARK: - Preferences
private extension SettingsScreen {
    var preferencesSection: some View {
        settingsGroup(header: "Preferences") {
            VStack(spacing: 0) {
                appearanceRow

                settingsDivider

                Button { coordinator.push(ProfileLocalRoute.territorialDisputes) } label: {
                    SettingsNavigationRow(
                        icon: "exclamationmark.triangle.fill",
                        iconColor: DesignSystem.Color.warning,
                        title: "Territorial disputes"
                    )
                }
                .buttonStyle(PressButtonStyle())

                settingsDivider

                Button { coordinator.push(ProfileLocalRoute.storage) } label: {
                    SettingsNavigationRow(
                        icon: "internaldrive.fill",
                        iconColor: DesignSystem.Color.textSecondary,
                        title: "Storage"
                    )
                }
                .buttonStyle(PressButtonStyle())
            }
        }
    }

    /// Mercator's straight grid, or Equal Earth's curved one with every country at its true size.
    var projectionRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: "map.fill", color: DesignSystem.Color.blue)
            Text("Map projection")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            MenuPicker(
                "Map projection",
                selection: $projection,
                selectedTitle: Text((MapProjectionKind(rawValue: projection) ?? .mercator).title)
            ) {
                ForEach(MapProjectionKind.allCases) { kind in
                    Text(kind.title).tag(kind.rawValue)
                }
            }
        }
        .settingsRowPadding()
    }

    var appearanceRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: "circle.lefthalf.filled", color: DesignSystem.Color.indigo)
            Text("Appearance")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            MenuPicker(
                "Appearance",
                selection: $selectedTheme,
                selectedTitle: Text(LocalizedStringKey(selectedTheme))
            ) {
                Label("Auto", systemImage: "circle.lefthalf.filled").tag("Auto")
                Label("Light", systemImage: "sun.max.fill").tag("Light")
                Label("Dark", systemImage: "moon.fill").tag("Dark")
            }
        }
        .settingsRowPadding()
    }
}

// MARK: - Language
private extension SettingsScreen {
    @ViewBuilder
    var languageSection: some View {
        if languageService.isChoosable {
            settingsGroup(header: "Language") {
                VStack(spacing: 0) {
                    languageRow
                    // Read on every return to the app, so a language added in iOS Settings shows the row.
                    if scenePhase == .active, languageService.isChoosableInSystemSettings {
                        settingsDivider
                        systemLanguageRow
                    }
                }
            }
        }
    }

    var languageRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: "globe", color: DesignSystem.Color.blue)
            Text("App language")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            MenuPicker(
                "App language",
                selection: languageSelection,
                selectedTitle: languageTitle(languageService.language)
            ) {
                ForEach(languageService.languages) { language in
                    languageTitle(language).tag(language)
                }
            }
        }
        .settingsRowPadding()
    }

    /// Opens Geografy's page in iOS Settings, where its language can be set as well.
    var systemLanguageRow: some View {
        Button(action: openAppSettings) {
            SettingsExternalRow(
                icon: "gearshape.fill",
                iconColor: DesignSystem.Color.textSecondary,
                title: "Language in iOS Settings"
            )
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityHint("Opens Geografy's page in the Settings app")
    }

    func languageTitle(_ language: AppLanguage) -> Text {
        Text(verbatim: "\(language.flagEmoji) \(language.endonym)")
    }

    var languageSelection: Binding<AppLanguage> {
        Binding {
            languageService.language
        } set: { language in
            guard language != languageService.language else { return }
            #if !os(tvOS)
            hapticsService.selection()
            #endif
            languageService.language = language
        }
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}

// MARK: - Sound & Haptics
private extension SettingsScreen {
    var soundAndHapticsSection: some View {
        settingsGroup(header: "Sound & Haptics") {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    icon: "iphone.radiowaves.left.and.right",
                    iconColor: DesignSystem.Color.pink,
                    title: "Haptic feedback",
                    isOn: $hapticFeedbackEnabled
                )

                settingsDivider

                SettingsToggleRow(
                    icon: "waveform",
                    iconColor: DesignSystem.Color.purple,
                    title: "Pronunciation",
                    isOn: $pronunciationEnabled
                )
            }
        }
    }
}

// MARK: - Notifications
private extension SettingsScreen {
    var notificationsSection: some View {
        settingsGroup(header: "Notifications") {
            NotificationSettingsRows()
        }
    }
}

// MARK: - About
private extension SettingsScreen {
    var aboutSection: some View {
        settingsGroup(header: "About") {
            VStack(spacing: 0) {
                rateAppRow
                #if !os(tvOS)
                settingsDivider
                shareAppRow
                #endif
                settingsDivider
                privacyPolicyRow
                settingsDivider
                termsOfServiceRow
            }
        }
    }

    var privacyPolicyRow: some View {
        Link(destination: privacyPolicyURL) {
            SettingsExternalRow(icon: "hand.raised.fill", iconColor: DesignSystem.Color.blue, title: "Privacy Policy")
        }
        .buttonStyle(PressButtonStyle())
    }

    var termsOfServiceRow: some View {
        Link(destination: termsOfServiceURL) {
            SettingsExternalRow(
                icon: "doc.text.fill",
                iconColor: DesignSystem.Color.textSecondary,
                title: "Terms of Service"
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var rateAppRow: some View {
        Button {
            #if !os(tvOS)
            hapticsService.impact(.light)
            #endif
            requestReview()
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                SettingsIconBadge(systemImage: "star.fill", color: DesignSystem.Color.warning)
                Text("Rate Geografy")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer()
                Image(systemName: "arrow.up.forward")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .settingsRowPadding()
        }
        .buttonStyle(PressButtonStyle())
    }

    #if !os(tvOS)
    var shareAppRow: some View {
        ShareLink(item: appStoreURL) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                SettingsIconBadge(systemImage: "square.and.arrow.up", color: DesignSystem.Color.accent)
                Text("Share Geografy")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer()
                Image(systemName: "arrow.up.forward")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .settingsRowPadding()
        }
        .buttonStyle(PressButtonStyle())
    }
    #endif
}

// MARK: - Developer
#if DEBUG
private extension SettingsScreen {
    var developerSection: some View {
        settingsGroup(header: "Developer") {
            Button { openTestingLab() } label: {
                SettingsNavigationRow(icon: "flask.fill", iconColor: DesignSystem.Color.orange, title: "Testing Lab")
            }
            .buttonStyle(PressButtonStyle())
        }
    }
}
#endif

// MARK: - Version Footer
private extension SettingsScreen {
    var versionFooter: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return Text("Geografy v\(version) (\(build))")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .accessibilityLabel("App version \(version)")
    }
}

// MARK: - Row Helpers
private extension SettingsScreen {
    func settingsPickerRow(
        icon: String,
        iconColor: Color,
        title: String,
        selection: Binding<String>,
        options: [String]
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: icon, color: iconColor)
            Text(title)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Picker("", selection: selection) {
                ForEach(options, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.menu)
            .tint(DesignSystem.Color.textSecondary)
        }
        .settingsRowPadding()
    }

    var settingsDivider: some View {
        SettingsDivider()
    }

    func settingsGroup(header: LocalizedStringKey, @ViewBuilder content: () -> some View) -> some View {
        SettingsGroup(header, content: content)
    }
}

// MARK: - Actions
private extension SettingsScreen {
    func requestReview() {
        #if !os(tvOS)
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }
        AppStore.requestReview(in: scene)
        #endif
    }

    var appStoreURL: URL { SettingsURLs.appStore }
    var privacyPolicyURL: URL { SettingsURLs.privacy }
    var termsOfServiceURL: URL { SettingsURLs.terms }
}
