import SwiftUI

public extension View {
    /// A screen's actions, pinned to the bottom within reach (article 11): above the home indicator or the tab
    /// bar, inset from the sides like the content, with the same small gap below on every screen. The content
    /// brings no padding of its own.
    func bottomActionBar(@ViewBuilder _ content: () -> some View) -> some View {
        safeAreaBar(edge: .bottom) {
            content()
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.xs)
        }
    }
}
