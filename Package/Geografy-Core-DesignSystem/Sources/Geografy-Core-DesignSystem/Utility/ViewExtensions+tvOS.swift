#if os(tvOS)
import SwiftUI

public enum NavigationBarTitleDisplayModeCompat {
    case automatic, inline, large
}

public extension View {
    func navigationBarTitleDisplayMode(
        _ displayMode: NavigationBarTitleDisplayModeCompat
    ) -> some View {
        self
    }
}
#endif
