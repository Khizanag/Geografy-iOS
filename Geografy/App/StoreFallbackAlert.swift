import SwiftUI

/// Says once, at launch, that progress isn't being saved, when the store couldn't be opened and the app runs on a
/// temporary one. Without it, everything earned in the session would vanish on the next launch unannounced.
private struct StoreFallbackAlert: ViewModifier {
    @State private var isPresented: Bool

    init(isUsingFallbackStore: Bool) {
        _isPresented = State(initialValue: isUsingFallbackStore)
    }

    func body(content: Content) -> some View {
        content
            .alert("Progress Isn't Being Saved", isPresented: $isPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("""
                    Geografy couldn't open its saved data, so anything you do now is kept only until you close \
                    the app. Restarting your device or updating the app may fix it.
                    """)
            }
    }
}

extension View {
    func storeFallbackAlert(isUsingFallbackStore: Bool) -> some View {
        modifier(StoreFallbackAlert(isUsingFallbackStore: isUsingFallbackStore))
    }
}
