import Geografy_Core_DesignSystem
import SwiftUI

public struct CircleCloseButton: View {
    @Environment(\.dismiss) private var dismiss

    public let onClose: (() -> Void)?

    public init(onClose: (() -> Void)? = nil) {
        self.onClose = onClose
    }

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
