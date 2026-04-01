import SwiftUI
import Geografy_Core_Service

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
        .presentationSizing(.form)
    }
}
