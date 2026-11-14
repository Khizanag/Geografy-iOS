import SwiftUI

/// The one way out of a running game: a flag in the leading toolbar slot. The screen confirms before ending.
public struct GiveUpButton: View {
    // MARK: - Properties
    private let action: () -> Void

    // MARK: - Init
    public init(action: @escaping () -> Void) {
        self.action = action
    }

    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            Label("Give Up", systemImage: "flag.fill")
                .foregroundStyle(DesignSystem.Color.error)
        }
    }
}
