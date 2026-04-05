import SwiftUI

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
        Button {
            if let onClose {
                onClose()
            } else {
                dismiss()
            }
        } label: {
            Image(systemName: "xmark")
                .foregroundStyle(DesignSystem.Color.iconPrimary)
        }
        .accessibilityLabel("Close")
    }
}
