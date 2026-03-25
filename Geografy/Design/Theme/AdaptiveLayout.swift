import SwiftUI

extension DesignSystem {
    enum AdaptiveLayout {
        /// Max content width for readable layouts on wide screens
        #if targetEnvironment(macCatalyst)
        static let maxContentWidth: CGFloat = 900
        #else
        static let maxContentWidth: CGFloat = 700
        #endif

        /// Max content width for full-width cards/sections
        static let maxWideContentWidth: CGFloat = 960

        /// Grid column minimum width for adaptive grids
        static let gridItemMinWidth: CGFloat = 100

        /// Grid column minimum width for card-style grids on wide screens
        static let wideGridItemMinWidth: CGFloat = 160
    }
}

// MARK: - Adaptive Environment

struct AdaptiveLayoutInfo {
    let horizontalSizeClass: UserInterfaceSizeClass?

    var isWideLayout: Bool {
        horizontalSizeClass == .regular
    }

    var gridColumns: Int {
        isWideLayout ? 4 : 3
    }

    var cardGridColumns: Int {
        isWideLayout ? 3 : 2
    }

    var listDetailColumns: Int {
        isWideLayout ? 2 : 1
    }
}

// MARK: - View Modifiers

struct ReadableContentWidth: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let maxWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: horizontalSizeClass == .regular ? maxWidth : .infinity)
            .frame(maxWidth: .infinity)
    }
}

extension View {
    /// Constrains content to a readable width on wide screens (iPad/Mac), centered
    func readableContentWidth(
        _ maxWidth: CGFloat = DesignSystem.AdaptiveLayout.maxContentWidth
    ) -> some View {
        modifier(ReadableContentWidth(maxWidth: maxWidth))
    }
}

// MARK: - Adaptive Grid Helper

extension View {
    /// Returns adaptive grid columns based on horizontal size class
    func adaptiveGridColumns(
        minimum: CGFloat = DesignSystem.AdaptiveLayout.gridItemMinWidth,
        wideMinimum: CGFloat = DesignSystem.AdaptiveLayout.wideGridItemMinWidth
    ) -> [GridItem] {
        [GridItem(.adaptive(minimum: minimum), spacing: DesignSystem.Spacing.sm)]
    }
}

struct AdaptiveGrid<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    let compactMinimum: CGFloat
    let regularMinimum: CGFloat
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content

    init(
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

    var body: some View {
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
