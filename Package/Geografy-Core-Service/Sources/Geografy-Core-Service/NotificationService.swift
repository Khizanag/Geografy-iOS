#if os(iOS)
import UserNotifications

public enum NotificationService {
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
