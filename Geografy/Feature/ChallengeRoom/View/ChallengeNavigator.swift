import SwiftUI
import Combine

// MARK: - ChallengeCoordinator

@MainActor
@Observable
final class ChallengeCoordinator {
    fileprivate var path: [ChallengeDestination] = []

    private let shouldDismissSubject = PassthroughSubject<Void, Never>()

    func push(_ destination: ChallengeDestination) {
        path.append(destination)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func dismiss() {
        shouldDismissSubject.send()
    }

    fileprivate var shouldDismissPublisher: AnyPublisher<Void, Never> {
        shouldDismissSubject.eraseToAnyPublisher()
    }
}

// MARK: - ChallengeDestination

enum ChallengeDestination: Hashable {
    case result(ChallengeRoom)
}

// MARK: - ChallengeNavigatorView

struct ChallengeNavigatorView<Root: View>: View {
    @Environment(\.dismiss) private var dismiss
    @State private var coordinator = ChallengeCoordinator()
    @ViewBuilder private var root: () -> Root

    init(@ViewBuilder root: @escaping () -> Root) {
        self.root = root
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            root()
                .navigationDestination(for: ChallengeDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
        .onReceive(coordinator.shouldDismissPublisher) {
            dismiss()
        }
        .environment(coordinator)
    }
}

// MARK: - Destination Factory

private extension ChallengeNavigatorView {
    @ViewBuilder
    func destinationView(for destination: ChallengeDestination) -> some View {
        switch destination {
        case .result(let room):
            ChallengeResultScreen(room: room) { coordinator.dismiss() }
                .navigationTitle("Results")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        CircleCloseButton { coordinator.dismiss() }
                    }
                }
        }
    }
}
