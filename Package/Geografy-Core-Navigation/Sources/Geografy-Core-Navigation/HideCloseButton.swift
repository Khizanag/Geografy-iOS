import SwiftUI

// MARK: - Hide Close Button
public struct HideCloseButtonKey: PreferenceKey {
    public static let defaultValue = false
    public static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

// MARK: - Close Button Placement
public struct CloseButtonLeadingKey: PreferenceKey {
    public static let defaultValue = false
    public static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

// MARK: - View Modifiers
public extension View {
    /// Hides the automatic close button provided by CoordinatedNavigationStack.
    func hideNavigationCloseButton(_ hidden: Bool = true) -> some View {
        preference(key: HideCloseButtonKey.self, value: hidden)
    }

    /// Moves the close button to leading when trailing has other toolbar items (HIG).
    func closeButtonPlacementLeading(_ leading: Bool = true) -> some View {
        preference(key: CloseButtonLeadingKey.self, value: leading)
    }
}
