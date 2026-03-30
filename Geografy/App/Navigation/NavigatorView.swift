import Combine
import SwiftUI

// MARK: - Coordinator
@MainActor
@Observable
final class Coordinator {
    fileprivate var path: [Destination] = []

    private let shouldDismissSubject = PassthroughSubject<Void, Never>()

    func push(_ destination: Destination) {
        path.append(destination)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func dismiss() {
        shouldDismissSubject.send()
    }

    fileprivate var shouldDismissPublisher: AnyPublisher<Void, Never> {
        shouldDismissSubject.eraseToAnyPublisher()
    }
}

// MARK: - NavigatorView
struct NavigatorView<Root: View>: View {
    @Environment(\.dismiss) private var dismiss
    @State private var coordinator = Coordinator()

    private let canBeDismissed: Bool
    @ViewBuilder private var root: () -> Root

    init(
        canBeDismissed: Bool = true,
        @ViewBuilder root: @escaping () -> Root
    ) {
        self.canBeDismissed = canBeDismissed
        self.root = root
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            rootContent
                .navigationDestination(for: Destination.self) { destination in
                    destination.content
                        .toolbar {
                            if canBeDismissed {
                                dismissToolbarItem
                            }
                        }
                }
        }
        .onReceive(coordinator.shouldDismissPublisher) {
            dismiss()
        }
        .environment(coordinator)
    }
}

// MARK: - Subviews
private extension NavigatorView {
    @ViewBuilder
    var rootContent: some View {
        if canBeDismissed {
            root()
                .toolbar {
                    dismissToolbarItem
                }
        } else {
            root()
        }
    }

    @ToolbarContentBuilder
    var dismissToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            CircleCloseButton { coordinator.dismiss() }
        }
    }
}
