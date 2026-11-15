import SwiftUI

/// A capsule filter chip. The chosen one is inked in the text color, the way iOS marks a filter,
/// so selection never leans on the accent green; the rest are quiet outlined capsules.
///
/// Lay several out with `ChipScrollRow`.
public struct SelectableChip<Icon: View>: View {
    // MARK: - Properties
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @ScaledMetric(relativeTo: .subheadline) private var minHeight: CGFloat = 36

    private let title: Text
    private let isSelected: Bool
    private let action: () -> Void
    private let icon: Icon

    // MARK: - Init
    public init(
        _ title: LocalizedStringKey,
        isSelected: Bool,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.init(text: Text(title), isSelected: isSelected, action: action, icon: icon)
    }

    /// For a title that's already text to show, such as a name from data.
    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        isSelected: Bool,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.init(text: Text(title), isSelected: isSelected, action: action, icon: icon)
    }

    private init(text: Text, isSelected: Bool, action: @escaping () -> Void, @ViewBuilder icon: () -> Icon) {
        self.title = text
        self.isSelected = isSelected
        self.action = action
        self.icon = icon()
    }

    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(PressButtonStyle())
        .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Subviews
private extension SelectableChip {
    var label: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            if isSelected, differentiateWithoutColor {
                Image(systemName: "checkmark")
                    .fontWeight(.bold)
                    .accessibilityHidden(true)
            }
            icon
                .foregroundStyle(isSelected ? DesignSystem.Color.background : DesignSystem.Color.textSecondary)
                .accessibilityHidden(true)
            title
                .foregroundStyle(isSelected ? DesignSystem.Color.background : DesignSystem.Color.textPrimary)
        }
        .font(DesignSystem.Font.subheadline)
        .fontWeight(isSelected ? .semibold : .medium)
        .lineLimit(1)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .frame(minHeight: minHeight)
        .background {
            Capsule()
                .fill(isSelected ? DesignSystem.Color.textPrimary : DesignSystem.Color.cardBackground)
        }
        .overlay {
            Capsule()
                .strokeBorder(DesignSystem.Color.dividerSubtle, lineWidth: 1)
                .opacity(isSelected ? 0 : 1)
        }
        .contentShape(Capsule())
    }
}

// MARK: - Convenience Inits
public extension SelectableChip where Icon == EmptyView {
    init(_ title: LocalizedStringKey, isSelected: Bool, action: @escaping () -> Void) {
        self.init(title, isSelected: isSelected, action: action) { EmptyView() }
    }

    @_disfavoredOverload
    init(_ title: some StringProtocol, isSelected: Bool, action: @escaping () -> Void) {
        self.init(title, isSelected: isSelected, action: action) { EmptyView() }
    }
}

public extension SelectableChip where Icon == Image {
    init(_ title: LocalizedStringKey, systemImage: String, isSelected: Bool, action: @escaping () -> Void) {
        self.init(title, isSelected: isSelected, action: action) { Image(systemName: systemImage) }
    }

    @_disfavoredOverload
    init(_ title: some StringProtocol, systemImage: String, isSelected: Bool, action: @escaping () -> Void) {
        self.init(title, isSelected: isSelected, action: action) { Image(systemName: systemImage) }
    }
}

// MARK: - Row
/// Chips side by side in a row that scrolls sideways, past the content's edges to the screen's.
public struct ChipScrollRow<Content: View>: View {
    // MARK: - Properties
    private let inset: CGFloat
    @ViewBuilder private let content: () -> Content

    // MARK: - Init
    /// - Parameter inset: Space before the first chip and after the last, for a row that runs edge to edge.
    public init(inset: CGFloat = 0, @ViewBuilder content: @escaping () -> Content) {
        self.inset = inset
        self.content = content
    }

    // MARK: - Body
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                content()
            }
            .padding(.vertical, DesignSystem.Spacing.xxs)
        }
        .contentMargins(.horizontal, inset, for: .scrollContent)
        .scrollClipDisabled()
    }
}
