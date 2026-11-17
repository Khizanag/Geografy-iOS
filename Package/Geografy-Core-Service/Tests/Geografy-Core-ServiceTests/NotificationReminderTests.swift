#if os(iOS)
@testable import Geografy_Core_Service
import Testing

@Suite("Reminder identifiers")
struct NotificationReminderTests {
    @Test("A scheduled reminder's identifier says which reminder it is")
    func identifierMapsToReminder() {
        #expect(NotificationService.Reminder(identifier: "daily-challenge-1763362800") == .dailyChallenge)
        #expect(NotificationService.Reminder(identifier: "streak-reminder-1763398800") == .streak)
        #expect(NotificationService.Reminder(identifier: "something-else") == nil)
    }
}
#endif
