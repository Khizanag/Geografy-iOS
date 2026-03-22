import SwiftUI

struct CircleCloseButton: View {
    @Environment(\.dismiss) private var dismiss

    private let onClose: (() -> Void)?

    init(onClose: (() -> Void)? = nil) {
        self.onClose = onClose
    }

    var body: some View {
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
    }
}
