import SwiftUI

public extension View {
    /// Makes a sheet exactly as tall as its content. At accessibility text sizes it opens full height and scrolls.
    ///
    /// The content runs to the sheet's bottom edge, so its own bottom padding sets the gap there: give it the same
    /// padding as its sides and buttons sit evenly inside the sheet.
    func fittedSheet() -> some View {
        modifier(FittedSheetModifier())
    }
}

// MARK: - Modifier
private struct FittedSheetModifier: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    // Only first guesses; the real values arrive once the sheet is laid out.
    @State private var contentHeight: CGFloat = 300
    @State private var bottomInset: CGFloat = 0

    func body(content: Content) -> some View {
        ScrollView {
            content
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { height in
                    contentHeight = height
                }
        }
        .scrollBounceBehavior(.basedOnSize)
        .ignoresSafeArea(.container, edges: .bottom)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.safeAreaInsets.bottom
        } action: { inset in
            bottomInset = inset
        }
        // A height detent leaves the bottom safe area below it, so take that back out of the measured height.
        .presentationDetents(dynamicTypeSize.isAccessibilitySize ? [.large] : [.height(contentHeight - bottomInset)])
    }
}
