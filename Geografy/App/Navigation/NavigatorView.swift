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
    @ViewBuilder private var root: () -> Root

    init(@ViewBuilder root: @escaping () -> Root) {
        self.root = root
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            root()
                .navigationDestination(for: Destination.self) { destination in
                    destination.content
                        .navigationBarBackButtonHidden()
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                CircleCloseButton { coordinator.dismiss() }
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
