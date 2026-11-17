import SwiftUI

public extension DesignSystem {
    enum AdaptiveLayout {
        /// Max content width for readable layouts on wide screens
        #if targetEnvironment(macCatalyst)
        public static let maxContentWidth: CGFloat = 900
        #else
        public static let maxContentWidth: CGFloat = 700
        #endif

        /// Max content width for full-width cards/sections
        public static let maxWideContentWidth: CGFloat = 960
    }
}

// MARK: - Adaptive Environment
public struct AdaptiveLayoutInfo {
    public let horizontalSizeClass: UserInterfaceSizeClass?

    public init(horizontalSizeClass: UserInterfaceSizeClass?) {
        self.horizontalSizeClass = horizontalSizeClass
    }

    public var isWideLayout: Bool {
        horizontalSizeClass == .regular
    }

    public var gridColumns: Int {
        isWideLayout ? 4 : 3
    }

    public var cardGridColumns: Int {
        isWideLayout ? 3 : 2
    }

    public var listDetailColumns: Int {
        isWideLayout ? 2 : 1
    }
}

// MARK: - View Modifiers
public struct ReadableContentWidth: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let maxWidth: CGFloat

    public init(maxWidth: CGFloat) {
        self.maxWidth = maxWidth
    }

    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: horizontalSizeClass == .regular ? maxWidth : .infinity)
            .frame(maxWidth: .infinity)
    }
}

public extension View {
    /// Constrains content to a readable width on wide screens (iPad/Mac), centered
    func readableContentWidth(
        _ maxWidth: CGFloat = DesignSystem.AdaptiveLayout.maxContentWidth
    ) -> some View {
        modifier(ReadableContentWidth(maxWidth: maxWidth))
    }
}

// MARK: - Adaptive Grid Helper
