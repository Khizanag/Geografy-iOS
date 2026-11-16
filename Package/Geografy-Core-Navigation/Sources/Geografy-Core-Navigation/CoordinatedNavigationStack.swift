import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - Coordinated Navigation Stack
public struct CoordinatedNavigationStack<Root: View>: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @Environment(\.routes) private var routes

    // Owned here so it survives re-renders; a navigator built inline in a parent's body would be
    // replaced on every update, dropping any sheet, cover, or push it was presenting.
    @State private var ownedNavigator = Navigator()
    private let providedNavigator: Navigator?
    public var showCloseButton: Bool = false
    @ViewBuilder public var root: () -> Root

    // MARK: - Init
    /// Drives the stack with a navigator the caller keeps alive, such as a tab's.
    public init(
        navigator: Navigator,
        showCloseButton: Bool = false,
        @ViewBuilder root: @escaping () -> Root
    ) {
        self.providedNavigator = navigator
        self.showCloseButton = showCloseButton
        self.root = root
    }

    /// Drives the stack with its own navigator, for sheets and covers.
    public init(
        showCloseButton: Bool = false,
        @ViewBuilder root: @escaping () -> Root
    ) {
        self.providedNavigator = nil
        self.showCloseButton = showCloseButton
        self.root = root
    }

    // MARK: - Body
    public var body: some View {
        @Bindable var navigator = providedNavigator ?? ownedNavigator
        NavigationStack(path: $navigator.path) {
            rootWithCloseButton
                .navigationDestination(for: Destination.self) { destination in
                    routes.screen(for: destination)
                }
        }
        .sheet(item: $navigator.activeSheet) { destination in
            DestinationSheetView(destination: destination)
        }
        .fullScreenCover(item: $navigator.activeCover) { destination in
            DestinationCoverView(destination: destination)
        }
        .environment(navigator)
        // Icons, menus, and alerts default to the label color; controls that should carry the
        // accent (switches, sliders, progress, prominent buttons) set it themselves.
        .tint(DesignSystem.Color.iconPrimary)
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

    let showCloseButton: Bool
    @ViewBuilder let content: () -> Content

    @State private var hideCloseButton = false
    @State private var closeButtonLeading = false

    var body: some View {
        content()
            .onPreferenceChange(HideCloseButtonKey.self) { hideCloseButton = $0 }
            .onPreferenceChange(CloseButtonLeadingKey.self) { closeButtonLeading = $0 }
            .toolbar {
                if showCloseButton, !hideCloseButton {
                    ToolbarItem(placement: closeButtonLeading ? .topBarLeading : .topBarTrailing) {
                        CircleCloseButton { dismiss() }
                    }
                }
            }
    }
}

// MARK: - Destination Cover View
private struct DestinationCoverView: View {
    @Environment(\.routes) private var routes

    let destination: Destination

    var body: some View {
        CoordinatedNavigationStack(showCloseButton: true) {
            routes.screen(for: destination)
        }
    }
}

// MARK: - Destination Sheet View
private struct DestinationSheetView: View {
    @Environment(\.routes) private var routes

    let destination: Destination

    var body: some View {
        CoordinatedNavigationStack(showCloseButton: true) {
            routes.screen(for: destination)
        }
    }
}
