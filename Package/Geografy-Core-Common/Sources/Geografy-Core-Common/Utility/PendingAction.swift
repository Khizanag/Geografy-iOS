import Foundation

/// One action waiting to run after a pause, such as moving to the next question once feedback has shown.
///
/// Scheduling again replaces the waiting action, and the action is dropped when its owner goes away, so a
/// screen that's gone or a step already passed never runs a stale one, as `DispatchQueue.asyncAfter` could.
/// Keep one in a view's `@State`.
@MainActor
public final class PendingAction {
    private var task: Task<Void, Never>?

    public init() {}

    isolated deinit {
        task?.cancel()
    }

    /// Runs `action` after `delay`, replacing any action still waiting.
    public func schedule(after delay: Duration, _ action: @escaping @MainActor () -> Void) {
        task?.cancel()
        task = Task {
            do {
                try await Task.sleep(for: delay)
            } catch {
                return
            }
            action()
        }
    }

    /// Drops the waiting action, if any.
    public func cancel() {
        task?.cancel()
        task = nil
    }
}
