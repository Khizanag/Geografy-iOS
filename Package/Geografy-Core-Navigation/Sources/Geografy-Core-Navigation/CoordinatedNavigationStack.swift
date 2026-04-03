import Geografy_Core_Common
import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - Destination Content Provider
public struct DestinationContentKey: EnvironmentKey {
    public static let defaultValue: (@MainActor @Sendable (Destination) -> AnyView)? = nil
}

public extension EnvironmentValues {
    var destinationContent: (@MainActor @Sendable (Destination) -> AnyView)? {
        get { self[DestinationContentKey.self] }
        set { self[DestinationContentKey.self] = newValue }
    }
}

public extension View {
    func destinationContentProvider(
        @ViewBuilder _ provider: @MainActor @Sendable @escaping (Destination) -> some View
    ) -> some View {
        environment(\.destinationContent, { @MainActor @Sendable in AnyView(provider($0)) })
    }
}

// MARK: - Coordinated Navigation Stack
public struct CoordinatedNavigationStack<Root: View>: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.destinationContent) private var destinationContent

    @Bindable public var navigator: Navigator
    public var showCloseButton: Bool = false
    @ViewBuilder public var root: () -> Root

    public init(
        navigator: Navigator,
        showCloseButton: Bool = false,
        @ViewBuilder root: @escaping () -> Root
    ) {
        self.navigator = navigator
        self.showCloseButton = showCloseButton
        self.root = root
    }

    public var body: some View {
        NavigationStack(path: $navigator.path) {
            rootWithCloseButton
                .navigationDestination(for: Destination.self) { destination in
                    destinationContent?(destination) ?? AnyView(EmptyView())
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
    @Environment(\.destinationContent) private var destinationContent

    let destination: Destination

    var body: some View {
        CoordinatedNavigationStack(
            navigator: Navigator(),
            showCloseButton: true
        ) {
            destinationContent?(destination) ?? AnyView(EmptyView())
        }
    }
}

// MARK: - Destination Sheet View
private struct DestinationSheetView: View {
    @Environment(\.destinationContent) private var destinationContent

    let destination: Destination

    var body: some View {
        CoordinatedNavigationStack(
            navigator: Navigator(),
            showCloseButton: true
        ) {
            destinationContent?(destination) ?? AnyView(EmptyView())
        }
        .presentationSizing(.form)
    }
}
