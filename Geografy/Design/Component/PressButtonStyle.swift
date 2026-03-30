import SwiftUI
#if !os(tvOS)
import UIKit
#endif

struct PressButtonStyle: ButtonStyle {
    #if !os(tvOS)
    var feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle = .light
    #endif

    func makeBody(configuration: Configuration) -> some View {
        PressButtonBody(configuration: configuration)
    }
}

// MARK: - Body
private struct PressButtonBody: View {
    #if !os(tvOS)
    @Environment(HapticsService.self) private var hapticsService
    #endif
    let configuration: ButtonStyleConfiguration

    var body: some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
            #if !os(tvOS)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    hapticsService.impact(.light)
                }
            }
            #endif
    }
}
