#if os(iOS)
import UserNotifications

/// The daily streak and challenge reminders. They're scheduled only while the person has them on
/// in Settings and iOS allows Geografy to notify.
public enum NotificationService {
    /// Where the person's choice is kept, under the key Settings has always used.
    public static let preferenceKey = "notificationsEnabled"

    /// Whether iOS lets Geografy notify.
    public enum Authorization: Sendable {
        /// Never asked: asking shows the system prompt.
        case notDetermined
        case allowed
        /// Turned off in iOS Settings, or refused at the prompt: only iOS Settings can turn it back on.
        case denied
    }

    public static func authorization() async -> Authorization {
        switch await UNUserNotificationCenter.current().notificationSettings().authorizationStatus {
        case .notDetermined: .notDetermined
        case .authorized, .provisional, .ephemeral: .allowed
        case .denied: .denied
        @unknown default: .denied
        }
    }

    /// Schedules the reminders when `enabled` and allowed, and removes them otherwise.
    public static func syncReminders(enabled: Bool) async {
        guard enabled, await authorization() == .allowed else {
            cancelAll()
            return
        }
        scheduleStreakReminder()
        scheduleDailyChallengeReminder()
    }

    public static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    public static func scheduleStreakReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["streak-reminder"])

        let content = UNMutableNotificationContent()
        content.title = "Keep your streak alive!"
        content.body = "Open Geografy today to maintain your daily streak."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 19
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "streak-reminder", content: content, trigger: trigger)
        center.add(request)
    }

    public static func scheduleDailyChallengeReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily-challenge"])

        let content = UNMutableNotificationContent()
        content.title = "New Daily Challenge!"
        content.body = "A new mystery country, flag sequence, and capital chain await you."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-challenge", content: content, trigger: trigger)
        center.add(request)
    }

    public static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
#endif
