import SwiftUI

public extension View {
    /// The app's one screen backdrop. Set as the navigation container's background, so it fills the
    /// whole screen in every orientation — under the bars, the tab bar, and the keyboard.
    ///
    /// Every screen uses this; change the backdrop here and the whole app follows.
    func screenBackground() -> some View {
        #if os(tvOS)
        background { AppBackdrop().ignoresSafeArea() }
        #else
        containerBackground(for: .navigation) { AppBackdrop() }
        #endif
    }
}

/// What every screen draws behind its content.
private struct AppBackdrop: View {
    var body: some View {
        DesignSystem.Color.background
    }
}
