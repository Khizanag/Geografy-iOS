#if os(iOS)
import BackgroundTasks
import WidgetKit

enum BackgroundTaskService {
    static let widgetRefreshID = "com.khizanag.geografy.widgetRefresh"

    static func registerTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: widgetRefreshID,
            using: nil
        ) { task in
            handleWidgetRefresh(task as! BGAppRefreshTask)
        }
    }

    static func scheduleWidgetRefresh() {
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
