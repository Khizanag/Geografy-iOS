import SwiftUI

public extension View {
    /// Sets a navigation page's backdrop as its container background, which fills the whole screen
    /// in every orientation — under the bars, the tab bar, and the keyboard.
    func screenBackground<Background: View>(@ViewBuilder _ background: () -> Background) -> some View {
        #if os(tvOS)
        self.background { background().ignoresSafeArea() }
        #else
        containerBackground(for: .navigation, content: background)
        #endif
    }

    /// The plain app background, filling the whole screen.
    func screenBackground() -> some View {
        screenBackground { DesignSystem.Color.background }
    }

    /// The app background with ambient color blobs, filling the whole screen.
    func screenBackground(_ preset: AmbientBlobsView.Preset) -> some View {
        screenBackground {
            ZStack {
                DesignSystem.Color.background
                AmbientBlobsView(preset)
            }
        }
    }
}
