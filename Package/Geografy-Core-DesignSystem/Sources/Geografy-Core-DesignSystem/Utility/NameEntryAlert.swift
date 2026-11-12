import SwiftUI

public extension View {
    /// An alert that asks for a name. The confirm button stays disabled until `isValid` accepts the
    /// trimmed name, and the buttons use the primary color rather than the app's accent.
    func nameEntryAlert(
        _ title: LocalizedStringKey,
        isPresented: Binding<Bool>,
        placeholder: LocalizedStringKey,
        confirmTitle: LocalizedStringKey,
        isValid: @escaping @MainActor (String) -> Bool,
        onConfirm: @escaping @MainActor (String) -> Void
    ) -> some View {
        modifier(
            NameEntryAlert(
                title: title,
                isPresented: isPresented,
                placeholder: placeholder,
                confirmTitle: confirmTitle,
                isValid: isValid,
                onConfirm: onConfirm
            )
        )
    }
}

private struct NameEntryAlert: ViewModifier {
    let title: LocalizedStringKey
    @Binding var isPresented: Bool
    let placeholder: LocalizedStringKey
    let confirmTitle: LocalizedStringKey
    let isValid: @MainActor (String) -> Bool
    let onConfirm: @MainActor (String) -> Void

    @State private var name = ""

    func body(content: Content) -> some View {
        content
            // Hosted on its own view so the alert's tint doesn't recolor the screen.
            .background {
                Color.clear
                    .alert(title, isPresented: $isPresented) {
                        TextField(placeholder, text: $name)
                        Button("Cancel", role: .cancel) { name = "" }
                        Button(confirmTitle) {
                            onConfirm(trimmedName)
                            name = ""
                        }
                        .disabled(!isValid(trimmedName))
                    }
                    .tint(DesignSystem.Color.iconPrimary)
            }
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
