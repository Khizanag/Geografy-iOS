import SwiftUI

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
    @ViewBuilder
    var rootWithCloseButton: some View {
        if showCloseButton {
            root()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        CircleCloseButton { dismiss() }
                    }
                }
        } else {
            root()
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
        .presentationDetents([.large])
    }
}
