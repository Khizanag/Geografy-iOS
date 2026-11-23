import SwiftUI

/// The system close button, for a bar that closes something other than the view that holds it.
public struct CircleCloseButton: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss

    public let onClose: (() -> Void)?

    // MARK: - Init
    public init(onClose: (() -> Void)? = nil) {
        self.onClose = onClose
    }

    // MARK: - Body
    public var body: some View {
        Button(role: .close) {
            if let onClose {
                onClose()
            } else {
                dismiss()
            }
        }
    }
}
