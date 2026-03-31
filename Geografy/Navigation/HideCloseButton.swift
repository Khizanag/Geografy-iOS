import SwiftUI

// MARK: - Hide Close Button
private struct HideCloseButtonKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var hideCloseButton: Bool {
        get { self[HideCloseButtonKey.self] }
        set { self[HideCloseButtonKey.self] = newValue }
    }
}

// MARK: - Close Button Placement
private struct CloseButtonLeadingKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var closeButtonLeading: Bool {
        get { self[CloseButtonLeadingKey.self] }
        set { self[CloseButtonLeadingKey.self] = newValue }
    }
}

// MARK: - View Modifiers
extension View {
    /// Hides the automatic close button provided by CoordinatedNavigationStack.
    func hideNavigationCloseButton(_ hidden: Bool = true) -> some View {
        environment(\.hideCloseButton, hidden)
    }

    /// Moves the close button to leading when trailing has other toolbar items (HIG).
    func closeButtonPlacementLeading(_ leading: Bool = true) -> some View {
        environment(\.closeButtonLeading, leading)
    }
}
