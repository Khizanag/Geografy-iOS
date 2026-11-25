import SwiftUI

/// The mark that says whether an item is chosen: an empty circle, or a plus for an item to add, that turns into a
/// filled check in `color`, so selection never rests on the tint alone. The symbol morphs from one to the other.
public struct SelectionMark: View {
    // MARK: - Kind
    public enum Kind {
        /// A radio-style circle, for a tile or a row that's chosen.
        case select
        /// A plus, for an item that's added to a list.
        case add

        var offSymbol: String {
            switch self {
            case .select: "circle"
            case .add: "plus.circle"
            }
        }
    }

    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let isSelected: Bool
    private let color: Color
    private let kind: Kind

    // MARK: - Init
    public init(isSelected: Bool, color: Color = DesignSystem.Color.accent, kind: Kind = .select) {
        self.isSelected = isSelected
        self.color = color
        self.kind = kind
    }

    // MARK: - Body
    public var body: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : kind.offSymbol)
            .font(DesignSystem.Font.title3)
            .foregroundStyle(isSelected ? color : DesignSystem.Color.textTertiary)
            .contentTransition(reduceMotion ? .opacity : .symbolEffect(.replace))
            .animation(reduceMotion ? .easeInOut(duration: 0.2) : .snappy(duration: 0.3), value: isSelected)
            .accessibilityHidden(true)
    }
}
