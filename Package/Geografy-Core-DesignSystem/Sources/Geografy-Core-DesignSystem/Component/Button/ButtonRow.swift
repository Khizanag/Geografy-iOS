import SwiftUI

/// Two or three full-width buttons sharing one row, such as Done and Play Again under a result,
/// so the bar above the tab bar takes one line. They stack at accessibility text sizes, where labels need the width.
///
/// Put the way out first and the main action last, nearest the thumb.
public struct ButtonRow<Content: View>: View {
    // MARK: - Properties
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ViewBuilder private let content: () -> Content

    // MARK: - Init
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    // MARK: - Body
    public var body: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: DesignSystem.Spacing.sm))
            : AnyLayout(HStackLayout(spacing: DesignSystem.Spacing.sm))
        layout {
            content()
        }
    }
}
