#if os(iOS)
import Geografy_Core_Service
import UserNotifications

/// Opens where a tapped reminder points: the challenge reminder opens today's challenge, the streak reminder the
/// Play tab. Set as the notification delegate at launch, so a tap that launched the app is handled too.
final class ReminderTapHandler: NSObject, UNUserNotificationCenterDelegate, Sendable {
    static let shared = ReminderTapHandler()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let reminder = NotificationService.Reminder(identifier: response.notification.request.identifier)
        await MainActor.run {
            switch reminder {
            case .dailyChallenge: AppRequests.shared.send(.dailyChallenge)
            case .streak: AppRequests.shared.send(.tab(.play))
            case nil: break
            }
        }
    }
}
#endif
