import SwiftUI

/// A capsule filter chip: plain glass at rest, prominent glass in its tint once chosen, with an optional count of
/// what the choice holds. The one chip every filter row uses, so chips look and answer alike on every screen.
///
/// Lay several out with `ChipScrollRow`; a chip that opens a menu of values is a `MenuChip`, and one that does a
/// single thing is an `ActionChip`.
public struct SelectableChip<Icon: View>: View {
    // MARK: - Properties
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let title: Text
    private let isSelected: Bool
    private let tint: Color
    private let count: Int?
    private let action: () -> Void
    private let icon: Icon

    // MARK: - Init
    /// - Parameters:
    ///   - tint: The chosen chip's glass, such as a status's own colour; the accent by default.
    ///   - count: How many items the choice holds, shown while it's chosen.
    public init(
        _ title: LocalizedStringKey,
        isSelected: Bool,
        tint: Color = DesignSystem.Color.accent,
        count: Int? = nil,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.init(text: Text(title), isSelected: isSelected, tint: tint, count: count, action: action, icon: icon)
    }

    /// For a title that's already text to show, such as a name from data.
    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        isSelected: Bool,
        tint: Color = DesignSystem.Color.accent,
        count: Int? = nil,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.init(text: Text(title), isSelected: isSelected, tint: tint, count: count, action: action, icon: icon)
    }

    private init(
        text: Text,
        isSelected: Bool,
        tint: Color,
        count: Int?,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.title = text
        self.isSelected = isSelected
        self.tint = tint
        self.count = count
        self.action = action
        self.icon = icon()
    }

    // MARK: - Body
    public var body: some View {
        Button {
            withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.75)) { action() }
        } label: {
            ChipLabel(title: title, isSelected: isSelected, count: count) { icon }
        }
        .chipGlass(isSelected: isSelected, tint: tint)
        .haptic(trigger: isSelected) { _, isSelected in isSelected ? .selection : nil }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Convenience Inits
public extension SelectableChip where Icon == EmptyView {
    init(
        _ title: LocalizedStringKey,
        isSelected: Bool,
        tint: Color = DesignSystem.Color.accent,
        count: Int? = nil,
        action: @escaping () -> Void
    ) {
        self.init(title, isSelected: isSelected, tint: tint, count: count, action: action) { EmptyView() }
    }

    @_disfavoredOverload
    init(
        _ title: some StringProtocol,
        isSelected: Bool,
        tint: Color = DesignSystem.Color.accent,
        count: Int? = nil,
        action: @escaping () -> Void
    ) {
        self.init(title, isSelected: isSelected, tint: tint, count: count, action: action) { EmptyView() }
    }
}

public extension SelectableChip where Icon == Image {
    init(
        _ title: LocalizedStringKey,
        systemImage: String,
        isSelected: Bool,
        tint: Color = DesignSystem.Color.accent,
        count: Int? = nil,
        action: @escaping () -> Void
    ) {
        self.init(title, isSelected: isSelected, tint: tint, count: count, action: action) {
            Image(systemName: systemImage)
        }
    }

    @_disfavoredOverload
    init(
        _ title: some StringProtocol,
        systemImage: String,
        isSelected: Bool,
        tint: Color = DesignSystem.Color.accent,
        count: Int? = nil,
        action: @escaping () -> Void
    ) {
        self.init(title, isSelected: isSelected, tint: tint, count: count, action: action) {
            Image(systemName: systemImage)
        }
    }
}

// MARK: - Menu Chip
/// A chip that opens a menu of values, such as a continent to filter by: the same glass as `SelectableChip`,
/// prominent in its tint while a value narrows the list, with a chevron that says it opens.
public struct MenuChip<Content: View>: View {
    // MARK: - Properties
    private let title: String
    private let systemImage: String
    private let isActive: Bool
    private let tint: Color
    @ViewBuilder private let content: () -> Content

    // MARK: - Init
    /// - Parameter isActive: Whether a value from the menu narrows the list now.
    public init(
        _ title: String,
        systemImage: String,
        isActive: Bool,
        tint: Color = DesignSystem.Color.accent,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.systemImage = systemImage
        self.isActive = isActive
        self.tint = tint
        self.content = content
    }

    // MARK: - Body
    public var body: some View {
        Menu(content: content) {
            ChipLabel(title: Text(title), isSelected: isActive, count: nil, showsMenuIndicator: true) {
                Image(systemName: systemImage)
            }
        }
        .menuStyle(.button)
        .chipGlass(isSelected: isActive, tint: tint)
        .haptic(.selection, trigger: title)
    }
}

// MARK: - Action Chip
/// A chip that does one thing when tapped, such as a setup fact that scrolls to its setting: the same plain glass
/// and label as the other chips, its glyph in `tint`, with a chevron when it leads somewhere.
public struct ActionChip: View {
    // MARK: - Properties
    @State private var pressCount = 0

    private let title: String
    private let systemImage: String
    private let tint: Color
    private let showsIndicator: Bool
    private let action: () -> Void

    // MARK: - Init
    /// - Parameters:
    ///   - tint: The glyph's color, such as a game's own color.
    ///   - showsIndicator: Whether a chevron says the chip leads to more.
    public init(
        _ title: String,
        systemImage: String,
        tint: Color = DesignSystem.Color.accent,
        showsIndicator: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
        self.showsIndicator = showsIndicator
        self.action = action
    }

    // MARK: - Body
    public var body: some View {
        Button {
            pressCount += 1
            action()
        } label: {
            ChipLabel(title: Text(title), isSelected: false, count: nil, showsMenuIndicator: showsIndicator) {
                Image(systemName: systemImage)
                    .foregroundStyle(tint)
            }
        }
        .chipGlass(isSelected: false, tint: tint)
        .haptic(.impact(weight: .light), trigger: pressCount)
    }
}

// MARK: - Label
/// What every chip shows: its glyph, its title, and, while chosen, its count; a menu chip adds a chevron.
private struct ChipLabel<Icon: View>: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    let title: Text
    let isSelected: Bool
    let count: Int?
    var showsMenuIndicator = false
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            if isSelected, differentiateWithoutColor {
                Image(systemName: "checkmark")
                    .fontWeight(.bold)
                    .accessibilityHidden(true)
            }
            icon()
                .font(DesignSystem.Font.caption)
                .accessibilityHidden(true)
            title
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
            if isSelected, let count, count > 0 {
                Text(count, format: .number)
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(.primary.opacity(DesignSystem.Opacity.tint), in: Capsule())
            }
            if showsMenuIndicator {
                Image(systemName: "chevron.down")
                    .font(DesignSystem.Font.caption2.weight(.semibold))
                    .accessibilityHidden(true)
            }
        }
        .lineLimit(1)
        .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textPrimary)
    }
}

// MARK: - Glass
private extension View {
    /// Prominent glass in `tint` while chosen, plain glass otherwise, always a capsule.
    @ViewBuilder
    func chipGlass(isSelected: Bool, tint: Color) -> some View {
        if isSelected {
            buttonStyle(.glassProminent)
                .buttonBorderShape(.capsule)
                .tint(tint)
        } else {
            buttonStyle(.glass)
                .buttonBorderShape(.capsule)
        }
    }
}

// MARK: - Row
/// Chips side by side in one glass container, in a row that scrolls sideways past the content's edges to the
/// screen's, and never clips a chip's glass as it swells under a press.
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
            GlassEffectContainer(spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    content()
                }
                .padding(.vertical, DesignSystem.Spacing.xxs)
            }
        }
        .contentMargins(.horizontal, inset, for: .scrollContent)
        .scrollClipDisabled()
    }
}
