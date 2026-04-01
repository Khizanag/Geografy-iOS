import SwiftUI
import WidgetKit

@main
struct GeografyWidgetsBundle: WidgetBundle {
    var body: some Widget {
        CountryOfDayWidget()
        DailyStreakWidget()
        WorldProgressWidget()
    }
}
