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

        /// Grid column minimum width for adaptive grids
        public static let gridItemMinWidth: CGFloat = 100

        /// Grid column minimum width for card-style grids on wide screens
        public static let wideGridItemMinWidth: CGFloat = 160
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
public extension View {
    /// Returns adaptive grid columns based on horizontal size class
    func adaptiveGridColumns(
        minimum: CGFloat = DesignSystem.AdaptiveLayout.gridItemMinWidth,
        wideMinimum: CGFloat = DesignSystem.AdaptiveLayout.wideGridItemMinWidth
    ) -> [GridItem] {
        [GridItem(.adaptive(minimum: minimum), spacing: DesignSystem.Spacing.sm)]
    }
}

public struct AdaptiveGrid<Content: View>: View {
    // MARK: - Properties
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let compactMinimum: CGFloat
    let regularMinimum: CGFloat
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content

    // MARK: - Init
    public init(
        compactMinimum: CGFloat = 100,
        regularMinimum: CGFloat = 140,
        spacing: CGFloat = DesignSystem.Spacing.sm,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.compactMinimum = compactMinimum
        self.regularMinimum = regularMinimum
        self.spacing = spacing
        self.content = content
    }

    // MARK: - Body
    public var body: some View {
        LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: horizontalSizeClass == .regular ? regularMinimum : compactMinimum),
                    spacing: spacing
                ),
            ],
            spacing: spacing
        ) {
            content()
        }
    }
}
