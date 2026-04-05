import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Navigation
import Geografy_Core_Service
import StoreKit
import SwiftUI

public struct SettingsScreen: View {
    // MARK: - Properties
    @Environment(AuthService.self) private var authService
    @Environment(Navigator.self) private var coordinator
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(TestingModeService.self) private var testingModeService
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif

    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("pronunciationEnabled") private var pronunciationEnabled = true
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true
    @AppStorage("selectedTheme") private var selectedTheme = "Auto"

    @State private var showDeleteConfirmation = false
    @State private var showSignOutConfirmation = false
    @State private var showDeveloperTools = false
    @State private var versionTapCount = 0

    // MARK: - Init
    public init() {}

    // MARK: - Body
    public var body: some View {
        scrollContent
            .background(DesignSystem.Color.background.ignoresSafeArea())
            .navigationTitle("Settings")
            #if !os(tvOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .task { await syncNotificationStatus() }
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
                soundAndHapticsSection
                notificationsSection
                aboutSection

                if showDeveloperTools {
                    developerSection
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                versionFooter
            }
            .animation(.easeInOut(duration: 0.3), value: showDeveloperTools)
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
            subscriptionRow
            settingsDivider
            signOutRow
            settingsDivider
            deleteAccountRow
        }
    }

    @ViewBuilder
    var subscriptionRow: some View {
        if subscriptionService.isPremium {
            premiumStatusRow
        } else {
            upgradePremiumRow
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
        Button { coordinator.sheet(.profile) } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ProfileAvatarView(
                    name: authService.currentProfile?.displayName ?? "Explorer",
                    size: DesignSystem.Size.md
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text(authService.currentProfile?.displayName ?? "Explorer")
                        .font(DesignSystem.Font.body)
                        .fontWeight(.medium)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text(authService.currentProfile?.email ?? "View profile")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .settingsRowPadding()
        }
        .buttonStyle(PressButtonStyle())
    }

    var guestProfileRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: "person.fill", color: DesignSystem.Color.textSecondary)
            VStack(alignment: .leading, spacing: 2) {
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
        Button { coordinator.push(.signIn) } label: {
            SettingsNavigationRow(
                icon: "person.badge.plus",
                iconColor: DesignSystem.Color.accent,
                title: "Sign In"
            )
        }
        .buttonStyle(PressButtonStyle())
    }

    var premiumStatusRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: "crown.fill", color: DesignSystem.Color.accent)
            Text("Premium")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Text("Active")
                .font(DesignSystem.Font.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.success)
        }
        .settingsRowPadding()
    }

    var upgradePremiumRow: some View {
        Button { coordinator.sheet(.paywall) } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                SettingsIconBadge(systemImage: "crown.fill", color: DesignSystem.Color.accent)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Upgrade to Premium")
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("Unlock all features")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .settingsRowPadding()
        }
        .buttonStyle(PressButtonStyle())
    }

    var signOutRow: some View {
        Button { showSignOutConfirmation = true } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                SettingsIconBadge(
                    systemImage: "rectangle.portrait.and.arrow.right",
                    color: DesignSystem.Color.warning
                )
                Text("Sign Out")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer()
            }
            .settingsRowPadding()
        }
        .buttonStyle(PressButtonStyle())
    }

    var deleteAccountRow: some View {
        Button { showDeleteConfirmation = true } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                SettingsIconBadge(systemImage: "trash.fill", color: DesignSystem.Color.error)
                Text("Delete Account")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.error)
                Spacer()
            }
            .settingsRowPadding()
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Preferences
private extension SettingsScreen {
    var preferencesSection: some View {
        settingsGroup(header: "Preferences") {
            VStack(spacing: 0) {
                appearanceRow

                settingsDivider

                Button { coordinator.push(.territorialDisputes) } label: {
                    SettingsNavigationRow(
                        icon: "exclamationmark.triangle.fill",
                        iconColor: DesignSystem.Color.warning,
                        title: "Territorial disputes"
                    )
                }
                .buttonStyle(PressButtonStyle())
            }
        }
    }

    var appearanceRow: some View {
        settingsPickerRow(
            icon: "circle.lefthalf.filled",
            iconColor: DesignSystem.Color.indigo,
            title: "Appearance",
            selection: $selectedTheme,
            options: ["Auto", "Light", "Dark"]
        )
    }
}

// MARK: - Sound & Haptics
private extension SettingsScreen {
    var soundAndHapticsSection: some View {
        settingsGroup(header: "Sound & Haptics") {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    icon: "speaker.wave.2.fill",
                    iconColor: DesignSystem.Color.blue,
                    title: "Sound effects",
                    isOn: $soundEffectsEnabled
                )

                settingsDivider

                SettingsToggleRow(
                    icon: "iphone.radiowaves.left.and.right",
                    iconColor: DesignSystem.Color.success,
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
            SettingsToggleRow(
                icon: "bell.fill",
                iconColor: DesignSystem.Color.accent,
                title: "Push notifications",
                isOn: Binding(
                    get: { notificationsEnabled },
                    set: { newValue in
                        if newValue {
                            requestNotificationPermission()
                        } else {
                            notificationsEnabled = false
                        }
                    }
                )
            )
        }
    }
}

// MARK: - About
private extension SettingsScreen {
    var aboutSection: some View {
        settingsGroup(header: "About") {
            VStack(spacing: 0) {
                rateAppRow
                settingsDivider
                shareAppRow
                settingsDivider
                privacyPolicyRow
                settingsDivider
                termsOfServiceRow

                if subscriptionService.isPremium {
                    settingsDivider
                    restorePurchasesRow
                }
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

    var restorePurchasesRow: some View {
        Button {
            Task { await subscriptionService.restorePurchases() }
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                SettingsIconBadge(systemImage: "arrow.clockwise", color: DesignSystem.Color.blue)
                Text("Restore Purchases")
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)
                Spacer()
            }
            .settingsRowPadding()
        }
        .buttonStyle(PressButtonStyle())
    }
}

// MARK: - Developer
private extension SettingsScreen {
    var developerSection: some View {
        settingsGroup(header: "Developer") {
            VStack(spacing: 0) {
                SettingsToggleRow(
                    icon: "hammer.fill",
                    iconColor: DesignSystem.Color.orange,
                    title: "Testing Mode",
                    isOn: Binding(
                        get: { testingModeService.isEnabled },
                        set: { testingModeService.isEnabled = $0 }
                    )
                )

                settingsDivider

                Button { coordinator.push(.featureFlags) } label: {
                    SettingsNavigationRow(
                        icon: "flag.fill",
                        iconColor: DesignSystem.Color.accent,
                        title: "Feature Flags"
                    )
                }
                .buttonStyle(PressButtonStyle())
            }
        }
    }
}

// MARK: - Version Footer
private extension SettingsScreen {
    var versionFooter: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return Button {
            versionTapCount += 1
            if versionTapCount >= 5, !showDeveloperTools {
                showDeveloperTools = true
                #if !os(tvOS)
                hapticsService.notification(.success)
                #endif
            }
        } label: {
            Text("Geografy v\(version) (\(build))")
                .font(DesignSystem.Font.caption2)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .buttonStyle(.plain)
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
        Divider()
            .background(DesignSystem.Color.cardBackgroundHighlighted)
            .padding(.leading, DesignSystem.Spacing.xxl + DesignSystem.Spacing.md)
    }

    func settingsGroup(header: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(header.uppercased())
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .padding(.horizontal, DesignSystem.Spacing.xs)
                .accessibilityAddTraits(.isHeader)
            CardView {
                content()
            }
        }
    }
}

// MARK: - Actions
private extension SettingsScreen {
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, _ in
            DispatchQueue.main.async {
                notificationsEnabled = granted
            }
        }
    }

    func syncNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        let authorized = settings.authorizationStatus == .authorized
        if notificationsEnabled, !authorized {
            notificationsEnabled = false
        }
    }

    func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }
        AppStore.requestReview(in: scene)
    }

    var appStoreURL: URL { SettingsURLs.appStore }
    var privacyPolicyURL: URL { SettingsURLs.privacy }
    var termsOfServiceURL: URL { SettingsURLs.terms }
}
