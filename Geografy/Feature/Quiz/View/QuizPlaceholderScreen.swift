import SwiftUI

struct QuizPlaceholderScreen: View {
    var body: some View {
        ComingSoonView(icon: "questionmark.circle.fill")
            .navigationTitle("Quiz")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    GeoCircleCloseButton()
                }
            }
    }
}
