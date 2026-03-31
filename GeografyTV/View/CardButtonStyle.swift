import SwiftUI

struct CardButtonStyle: ButtonStyle {
    @Environment(\.isFocused) private var isFocused

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .shadow(color: .white.opacity(isFocused ? 0.2 : 0), radius: isFocused ? 12 : 0)
            .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}
