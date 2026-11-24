import SwiftUI

public extension View {
    /// A screen's actions, pinned to the bottom within reach (article 11): right on the home indicator's inset or
    /// the tab bar's, which already leave room below, and inset from the sides like the content. The content brings
    /// no padding of its own.
    func bottomActionBar(@ViewBuilder _ content: () -> some View) -> some View {
        safeAreaBar(edge: .bottom) {
            content()
                .padding(.horizontal, DesignSystem.Spacing.md)
        }
    }
}
