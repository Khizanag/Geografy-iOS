import SwiftUI

public extension View {
    /// A screen's actions, pinned to the bottom within reach (article 11), inset from the sides like the content.
    /// Above the home indicator they sit right on its inset, which already leaves room below; above a tab bar they
    /// keep a small gap, since the tab bar's inset ends at its glass. The content brings no padding of its own.
    func bottomActionBar(@ViewBuilder _ content: () -> some View) -> some View {
        safeAreaBar(edge: .bottom) {
            BottomActionBarContent(content: content())
        }
    }

    /// Marks content shown above the tab bar, so its bottom actions keep a gap from the bar. Sheets and covers
    /// set it back to false.
    func sitsAboveTabBar(_ sitsAboveTabBar: Bool = true) -> some View {
        environment(\.sitsAboveTabBar, sitsAboveTabBar)
    }
}

public extension EnvironmentValues {
    @Entry var sitsAboveTabBar = false
}

private struct BottomActionBarContent<Content: View>: View {
    @Environment(\.sitsAboveTabBar) private var sitsAboveTabBar

    let content: Content

    var body: some View {
        content
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.bottom, sitsAboveTabBar ? DesignSystem.Spacing.xs : 0)
    }
}
