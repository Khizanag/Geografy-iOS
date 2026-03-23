import WidgetKit
import SwiftUI

@main
struct GeografyWidgetsBundle: WidgetBundle {
    var body: some Widget {
        CountryOfDayWidget()
        DailyStreakWidget()
        WorldProgressWidget()
    }
}
