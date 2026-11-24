import SwiftUI

/// A card of tappable rows with inset dividers, like a grouped list but in the app's card style.
public struct RowListCard<Item: Identifiable, Row: View>: View {
    // MARK: - Properties
    private let items: [Item]
    private let dividerInset: CGFloat
    private let row: (Item) -> Row
    private let menu: RowListMenu<Item>?

    // MARK: - Init
    /// - Parameters:
    ///   - dividerInset: Where dividers start, usually just past the row's leading flag or icon.
    ///   - menu: Each row's long-press preview and menu, and its swipe to remove when the menu can remove it.
    public init(
        _ items: [Item],
        dividerInset: CGFloat,
        menu: RowListMenu<Item>? = nil,
        @ViewBuilder row: @escaping (Item) -> Row
    ) {
        self.items = items
        self.dividerInset = dividerInset
        self.menu = menu
        self.row = row
    }

    // MARK: - Body
    public var body: some View {
        CardView {
            // Lazy, so a list of every country only builds the rows on screen.
            LazyVStack(spacing: 0) {
                ForEach(items) { item in
                    if let menu {
                        row(item).rowListMenu(menu, for: item)
                    } else {
                        row(item)
                    }
                    if item.id != items.last?.id {
                        Divider()
                            .padding(.leading, dividerInset)
                    }
                }
            }
        }
    }
}

/// Padding and hit area shared by rows inside a `RowListCard`.
public extension View {
    func rowListCardRow() -> some View {
        padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
    }
}

public enum RowListCardLayout {
    /// The width of a fixed-width inline flag, as `FlagView` lays it out.
    public static let flagWidth = DesignSystem.Size.Flag.inline * 1.6
    /// Two inline flags side by side.
    public static let flagPairWidth = flagWidth * 2 + DesignSystem.Spacing.xxs
    /// A small `IconBadge`, as list rows lead with it.
    public static let iconBadgeWidth = IconBadge.Size.small.diameter

    /// Divider inset for rows that lead with a view of the given width.
    public static func dividerInset(after leadingWidth: CGFloat) -> CGFloat {
        DesignSystem.Spacing.md + leadingWidth + DesignSystem.Spacing.sm
    }
}
