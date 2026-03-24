import SwiftUI
import UIKit

struct PressButtonStyle: ButtonStyle {
    var feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light

    func makeBody(configuration: Configuration) -> some View {
        PressButtonBody(configuration: configuration, feedbackStyle: feedbackStyle)
    }
}

// MARK: - Body

private struct PressButtonBody: View {
    @Environment(HapticsService.self) private var hapticsService
    let configuration: ButtonStyleConfiguration
    let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle

    var body: some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    hapticsService.impact(feedbackStyle)
                }
            }
    }
}
