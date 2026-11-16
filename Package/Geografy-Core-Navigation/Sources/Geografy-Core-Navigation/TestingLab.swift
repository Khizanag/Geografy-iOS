#if DEBUG
import Foundation

/// The developer tools screen, which the app shows over everything. Debug builds only.
public enum TestingLab {
    /// Post to open the Testing Lab from anywhere, such as a settings row.
    public static let openNotification = Notification.Name("TestingLab.open")
}
#endif
