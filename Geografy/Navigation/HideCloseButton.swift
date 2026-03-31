import SwiftUI

// MARK: - Environment Key
private struct HideCloseButtonKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var hideCloseButton: Bool {
        get { self[HideCloseButtonKey.self] }
        set { self[HideCloseButtonKey.self] = newValue }
    }
}

// MARK: - View Modifier
extension View {
    func hideNavigationCloseButton(_ hidden: Bool = true) -> some View {
        environment(\.hideCloseButton, hidden)
    }
}
