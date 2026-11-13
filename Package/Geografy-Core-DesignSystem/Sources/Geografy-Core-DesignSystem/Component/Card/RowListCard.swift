import SwiftUI

/// A card of tappable rows with inset dividers, like a grouped list but in the app's card style.
public struct RowListCard<Item: Identifiable, Row: View>: View {
    // MARK: - Properties
    private let items: [Item]
    private let dividerInset: CGFloat
    private let row: (Item) -> Row

    // MARK: - Init
    /// - Parameter dividerInset: Where dividers start, usually just past the row's leading flag or icon.
    public init(_ items: [Item], dividerInset: CGFloat, @ViewBuilder row: @escaping (Item) -> Row) {
        self.items = items
        self.dividerInset = dividerInset
        self.row = row
    }

    // MARK: - Body
    public var body: some View {
        CardView(cornerRadius: DesignSystem.CornerRadius.large) {
            VStack(spacing: 0) {
                ForEach(items) { item in
                    row(item)
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

    /// Divider inset for rows that lead with a view of the given width.
    public static func dividerInset(after leadingWidth: CGFloat) -> CGFloat {
        DesignSystem.Spacing.md + leadingWidth + DesignSystem.Spacing.sm
    }
}
