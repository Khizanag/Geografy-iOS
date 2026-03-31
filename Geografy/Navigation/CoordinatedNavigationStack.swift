import SwiftUI

// MARK: - Hide Close Button Environment Key
private struct HideCloseButtonKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var hideCloseButton: Bool {
        get { self[HideCloseButtonKey.self] }
        set { self[HideCloseButtonKey.self] = newValue }
    }
}

extension View {
    func hideNavigationCloseButton(_ hidden: Bool = true) -> some View {
        environment(\.hideCloseButton, hidden)
    }
}

// MARK: - Coordinated Navigation Stack
struct CoordinatedNavigationStack<Root: View>: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var navigator: Navigator
    var showCloseButton: Bool = false
    @ViewBuilder var root: () -> Root

    var body: some View {
        NavigationStack(path: $navigator.path) {
            rootWithCloseButton
                .navigationDestination(for: Destination.self) { destination in
                    destination.content
                }
        }
        .sheet(item: $navigator.activeSheet) { destination in
            DestinationSheetView(destination: destination)
        }
        .fullScreenCover(item: $navigator.activeCover) { destination in
            DestinationCoverView(destination: destination)
        }
        .environment(navigator)
    }
}

// MARK: - Subviews
private extension CoordinatedNavigationStack {
    var rootWithCloseButton: some View {
        CloseButtonWrapper(showCloseButton: showCloseButton) {
            root()
        }
    }
}

// MARK: - Close Button Wrapper
private struct CloseButtonWrapper<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.hideCloseButton) private var hideCloseButton

    let showCloseButton: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .toolbar {
                if showCloseButton, !hideCloseButton {
                    ToolbarItem(placement: .topBarLeading) {
                        CircleCloseButton { dismiss() }
                    }
                }
            }
    }
}

// MARK: - Destination Cover View
private struct DestinationCoverView: View {
    let destination: Destination

    var body: some View {
        CoordinatedNavigationStack(
            navigator: Navigator(),
            showCloseButton: true
        ) {
            destination.content
        }
    }
}

// MARK: - Destination Sheet View
private struct DestinationSheetView: View {
    let destination: Destination

    var body: some View {
        CoordinatedNavigationStack(
            navigator: Navigator(),
            showCloseButton: true
        ) {
            destination.content
        }
    }
}
