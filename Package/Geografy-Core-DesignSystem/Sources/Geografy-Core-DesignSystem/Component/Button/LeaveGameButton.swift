import SwiftUI

/// The one way out of a running game: the system close button in the leading toolbar slot. The screen confirms
/// before ending, since leaving loses the game.
public struct LeaveGameButton: View {
    // MARK: - Properties
    private let action: () -> Void

    // MARK: - Init
    public init(action: @escaping () -> Void) {
        self.action = action
    }

    // MARK: - Body
    public var body: some View {
        Button(role: .close, action: action)
    }
}
