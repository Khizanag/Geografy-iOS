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

    /// What a reminder is for, which decides where tapping it goes.
    public enum Reminder: String, Sendable {
        case dailyChallenge = "daily-challenge"
        case streak = "streak-reminder"

        /// The reminder a delivered notification came from.
        public init?(identifier: String) {
            guard let match = [Self.dailyChallenge, .streak].first(where: { identifier.hasPrefix($0.rawValue) })
            else { return nil }
            self = match
        }
    }

    /// Days ahead the reminders are scheduled; opening the app schedules them again.
    static let daysAhead = 14

    /// Schedules the reminders when `enabled` and allowed, and removes them otherwise. Each day gets its own
    /// reminders, so today's are left out once something has been learned today.
    public static func syncReminders(enabled: Bool, learnedToday: Bool) async {
        cancelAll()
        guard enabled, await authorization() == .allowed else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        for offset in 0..<daysAhead {
            if offset == 0, learnedToday { continue }
            guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            schedule(.dailyChallenge, on: day, hour: 9)
            schedule(.streak, on: day, hour: 19)
        }
    }

    public static func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    public static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - Scheduling
private extension NotificationService {
    static func schedule(_ reminder: Reminder, on day: Date, hour: Int) {
        let calendar = Calendar.current
        guard let fireDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: day),
              fireDate > .now else { return }

        let content = UNMutableNotificationContent()
        switch reminder {
        case .dailyChallenge:
            content.title = String(localized: "Today's challenge is ready")
            content.body = String(localized: "A new Daily Challenge is waiting for you.")
        case .streak:
            content.title = String(localized: "Keep your streak going")
            content.body = String(localized: "A quiz, a game, or a few flashcards today keeps it alive.")
        }
        content.sound = .default

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "\(reminder.rawValue)-\(Int(fireDate.timeIntervalSince1970))"
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        )
    }
}
#endif
