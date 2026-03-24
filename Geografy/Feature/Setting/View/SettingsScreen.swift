import SwiftUI
import UserNotifications

struct SettingsScreen: View {
    @Environment(TabCoordinator.self) private var coordinator
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(AuthService.self) private var authService
    @Environment(TestingModeService.self) private var testingModeService

    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedbackEnabled = true
    @AppStorage("pronunciationEnabled") private var pronunciationEnabled = true
    @AppStorage("showCorrectAnswer") private var showCorrectAnswer = true
    @AppStorage("selectedTheme") private var selectedTheme = "Auto"

    @State private var showSignIn = false
    @State private var showDeleteConfirmation = false
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                premiumSection
                accountSection
                appearanceSection
                generalSection
                mapSection
                quizSection
                developerSection
                appVersionInfo
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CircleCloseButton()
            }
        }
        .toolbarBackground(DesignSystem.Color.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task { await syncNotificationStatus() }
        .sheet(isPresented: $showSignIn) {
            SignInOptionsSheet()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallScreen()
        }
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
    }
}

// MARK: - Premium Section

private extension SettingsScreen {
    @ViewBuilder
    var premiumSection: some View {
        if subscriptionService.isPremium {
            settingsGroup(header: "Subscription") {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    SettingsIconBadge(systemImage: "crown.fill", color: DesignSystem.Color.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Geografy Premium")
                            .font(DesignSystem.Font.body)
                            .fontWeight(.medium)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text("Active subscription")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.success)
                    }
                    Spacer()
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                settingsDivider
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
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                }
                .buttonStyle(PressButtonStyle())
            }
        } else {
            settingsGroup(header: "Premium") {
                Button { showPaywall = true } label: {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        SettingsIconBadge(systemImage: "crown.fill", color: DesignSystem.Color.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Upgrade to Premium")
                                .font(DesignSystem.Font.body)
                                .fontWeight(.medium)
                                .foregroundStyle(DesignSystem.Color.textPrimary)
                            Text("Unlock all quiz types & advanced stats")
                                .font(DesignSystem.Font.caption)
                                .foregroundStyle(DesignSystem.Color.textTertiary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                }
                .buttonStyle(PressButtonStyle())
            }
        }
    }
}

// MARK: - Account Section

private extension SettingsScreen {
    @ViewBuilder
    var accountSection: some View {
        if authService.isGuest {
            guestAccountSection
        } else {
            authenticatedAccountSection
        }
    }

    var guestAccountSection: some View {
        settingsGroup(header: "Account") {
            HStack(spacing: DesignSystem.Spacing.sm) {
                SettingsIconBadge(systemImage: "person.fill", color: DesignSystem.Color.textSecondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Guest")
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    Text("Progress is saved on this device only")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)

            settingsDivider

            Button {
                showSignIn = true
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    SettingsIconBadge(systemImage: "person.badge.plus", color: DesignSystem.Color.accent)
                    Text("Sign In with Apple")
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.accent)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
            .buttonStyle(PressButtonStyle())
        }
    }

    @ViewBuilder
    var authenticatedAccountSection: some View {
        let profile = authService.currentProfile
        settingsGroup(header: "Account") {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Color.accent.opacity(0.15))
                        .frame(width: DesignSystem.Size.md, height: DesignSystem.Size.md)
                    Image(systemName: "person.fill")
                        .font(DesignSystem.Font.headline)
                        .foregroundStyle(DesignSystem.Color.accent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(profile?.displayName ?? "Explorer")
                        .font(DesignSystem.Font.body)
                        .fontWeight(.medium)
                        .foregroundStyle(DesignSystem.Color.textPrimary)
                    if let email = profile?.email {
                        Text(email)
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                    } else {
                        Text("Signed in with Apple")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textTertiary)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)

            settingsDivider

            Button {
                authService.signOut()
            } label: {
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
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
            .buttonStyle(PressButtonStyle())

            settingsDivider

            Button {
                showDeleteConfirmation = true
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    SettingsIconBadge(systemImage: "trash.fill", color: DesignSystem.Color.error)
                    Text("Delete Account")
                        .font(DesignSystem.Font.body)
                        .foregroundStyle(DesignSystem.Color.error)
                    Spacer()
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
            }
            .buttonStyle(PressButtonStyle())
        }
    }
}

// MARK: - Sections

private extension SettingsScreen {
    var appearanceSection: some View {
        settingsGroup(header: "Appearance") {
            settingsPickerRow(
                icon: "circle.lefthalf.filled",
                iconColor: DesignSystem.Color.indigo,
                title: "Theme",
                selection: $selectedTheme,
                options: ["Auto", "Light", "Dark"]
            )
        }
    }

    var generalSection: some View {
        settingsGroup(header: "General") {
            SettingsToggleRow(
                icon: "bell.fill",
                iconColor: DesignSystem.Color.accent,
                title: "Notifications",
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

            settingsDivider

            SettingsToggleRow(
                icon: "iphone.radiowaves.left.and.right",
                iconColor: Color(hex: "00C9A7"),
                title: "Haptic feedback",
                isOn: $hapticFeedbackEnabled
            )

            settingsDivider

            SettingsToggleRow(
                icon: "speaker.wave.2.fill",
                iconColor: DesignSystem.Color.blue,
                title: "Pronunciation",
                isOn: $pronunciationEnabled
            )
        }
    }

    var mapSection: some View {
        settingsGroup(header: "Map") {
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

    var quizSection: some View {
        settingsGroup(header: "Quiz") {
            SettingsToggleRow(
                icon: "checkmark.circle.fill",
                iconColor: DesignSystem.Color.success,
                title: "Show correct answer",
                isOn: $showCorrectAnswer
            )
        }
    }

    var developerSection: some View {
        settingsGroup(header: "Developer") {
            SettingsToggleRow(
                icon: "hammer.fill",
                iconColor: DesignSystem.Color.orange,
                title: "Testing Mode",
                isOn: Binding(
                    get: { testingModeService.isEnabled },
                    set: { testingModeService.isEnabled = $0 }
                )
            )
        }
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
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    var settingsDivider: some View {
        Divider()
            .background(DesignSystem.Color.cardBackgroundHighlighted)
            .padding(.leading, DesignSystem.Spacing.xxl)
    }
}

// MARK: - Helpers

private extension SettingsScreen {
    func settingsGroup(header: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(header.uppercased())
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .padding(.horizontal, DesignSystem.Spacing.xs)
            CardView {
                VStack(spacing: 0) {
                    content()
                }
            }
        }
    }

    var appVersionInfo: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return Text("Geografy v\(version) (\(build))")
            .font(DesignSystem.Font.caption2)
            .foregroundStyle(DesignSystem.Color.textTertiary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, DesignSystem.Spacing.xs)
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
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
}

// MARK: - Settings Row Components

private struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: icon, color: iconColor)
            Text(title)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(DesignSystem.Color.success)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

private struct SettingsNavigationRow: View {
    let icon: String
    let iconColor: Color
    let title: String

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: icon, color: iconColor)
            Text(title)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .contentShape(Rectangle())
    }
}

private struct SettingsIconBadge: View {
    let systemImage: String
    let color: Color

    var body: some View {
        Image(systemName: systemImage)
            .font(DesignSystem.IconSize.medium)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .frame(width: DesignSystem.Size.md, height: DesignSystem.Size.md)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
