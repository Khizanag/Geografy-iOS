#if os(iOS)
import BackgroundTasks
import WidgetKit

public enum BackgroundTaskService {
    public static let widgetRefreshID = "com.khizanag.geografy.widgetRefresh"

    public static func registerTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: widgetRefreshID,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            handleWidgetRefresh(refreshTask)
        }
    }

    public static func scheduleWidgetRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: widgetRefreshID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func handleWidgetRefresh(_ task: BGAppRefreshTask) {
        WidgetCenter.shared.reloadAllTimelines()
        task.setTaskCompleted(success: true)
        scheduleWidgetRefresh()
    }
}
#endif
