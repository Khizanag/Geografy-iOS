import SwiftUI

public extension View {
    /// Makes a sheet exactly as tall as its content, under a navigation bar or not. At accessibility text sizes
    /// it opens full height and scrolls.
    ///
    /// Leave the content without a background: below full height, iOS draws the sheet in Liquid Glass.
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
    @State private var insets = EdgeInsets()

    func body(content: Content) -> some View {
        ScrollView {
            content
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.size.height
                } action: { height in
                    contentHeight = height.rounded()
                }
        }
        .scrollBounceBehavior(.basedOnSize)
        .ignoresSafeArea(.container, edges: .bottom)
        .onGeometryChange(for: EdgeInsets.self) { proxy in
            proxy.safeAreaInsets
        } action: { newInsets in
            insets.top = newInsets.top.rounded()
            // While the sheet settles, its bottom inset drops to zero and eases back; following it opened the
            // sheet that much too tall and then shrank it. The home indicator's inset never changes, so keep it.
            if newInsets.bottom > 0 {
                insets.bottom = newInsets.bottom.rounded()
            }
        }
        .presentationDetents(dynamicTypeSize.isAccessibilitySize ? [.large] : [.height(sheetHeight)])
    }

    /// The content plus the navigation bar above it, if any. A height detent leaves the bottom safe area below it,
    /// so that comes back out of the measured height.
    var sheetHeight: CGFloat {
        contentHeight + insets.top - insets.bottom
    }
}
