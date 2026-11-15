import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI
#if os(iOS)
import UIKit
#endif

/// The reminders switch, and a way into iOS Settings when iOS has notifications for Geografy turned off.
///
/// Once turned off in iOS Settings, iOS no longer shows its prompt, so turning the switch on there
/// opens Geografy's notification settings instead, and switches on when the person comes back allowed.
struct NotificationSettingsRows: View {
    // MARK: - Properties
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage(NotificationService.preferenceKey) private var isEnabled = false

    @State private var authorization: NotificationService.Authorization?
    @State private var isWaitingForSystemSettings = false

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            SettingsToggleRow(
                icon: "bell.fill",
                iconColor: DesignSystem.Color.accent,
                title: "Push notifications",
                isOn: Binding(
                    get: { isEnabled },
                    set: { isOn in Task { await setEnabled(isOn) } }
                )
            )
            if authorization == .denied {
                SettingsDivider()
                systemSettingsRow
            }
        }
        // Checked again on each return to the app, as the person may have changed it in iOS Settings.
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            await refresh()
        }
    }
}

// MARK: - Subviews
private extension NotificationSettingsRows {
    var systemSettingsRow: some View {
        Button(action: openNotificationSettings) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                SettingsExternalRow(
                    icon: "bell.slash.fill",
                    iconColor: DesignSystem.Color.textSecondary,
                    title: "Turn On in iOS Settings"
                )
                Text("Notifications are off for Geografy in iOS Settings.")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.sm)
            }
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityHint("Opens Geografy's notification settings in the Settings app")
    }
}

// MARK: - Actions
private extension NotificationSettingsRows {
    func setEnabled(_ isOn: Bool) async {
        guard isOn else {
            isEnabled = false
            isWaitingForSystemSettings = false
            await NotificationService.syncReminders(enabled: false)
            return
        }

        let current = await NotificationService.authorization()
        switch current {
        case .allowed:
            isEnabled = true
        case .notDetermined:
            isEnabled = await NotificationService.requestPermission()
        case .denied:
            isWaitingForSystemSettings = true
            openNotificationSettings()
        }
        authorization = await NotificationService.authorization()
        await NotificationService.syncReminders(enabled: isEnabled)
    }

    func refresh() async {
        let current = await NotificationService.authorization()
        authorization = current
        if current == .allowed, isWaitingForSystemSettings {
            isEnabled = true
            isWaitingForSystemSettings = false
        } else if current != .allowed {
            isEnabled = false
        }
        await NotificationService.syncReminders(enabled: isEnabled)
    }

    func openNotificationSettings() {
        #if os(iOS)
        guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        openURL(url)
        #endif
    }
}
